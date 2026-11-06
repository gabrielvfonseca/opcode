# Personal Commands In Embedded QuickJS

**Status:** implemented. Bun is gone from Opcode: the user's config runs
in-process in QuickJS, with no external runtime and no child process.

## What Bun Hosted

Before this change, `personal_commands` spawned Bun on the managed
`@opcode/commands` SDK (`sdk/commands`: built `dist` in the macOS bundle,
embedded TypeScript `src` on Windows and Linux) inside a provisioned
`~/.config/opcode` workspace (`package.json`, `bun.lock`, `node_modules`,
`.opcode-sdk`, Effect pinned to the SDK's version, `bun update` on SDK changes).
Rust talked to the host over NDJSON: a registration, then `invoke` and
`transform` requests, `toolCall` frames for every native action and
`toolResult` replies, generations, retirement, and restart backoff.

What a config could do:

- **Commands:** `phrases`, `group`, `description`, `when` (application or
  browser host), typed `captures` (`digit`, `letter`, `choice`, `union`,
  `text`), and either a fixed `action` or a `run` handler. Handlers got
  `{ opcode, context, captures }`, where `opcode.openUrl/openApplication/openPath/press/typeText`
  sent a native tool call and resolved with its result. Effect handlers used
  `@opcode/commands/effect`.
- **Transformations:** `(text, context) => string | Promise<string>`, chained
  as one stage.
- **Dictation controls:** declarative `start`/`stop`/`send`/`cancel` phrases.
- Anything Bun offers: npm packages, `fetch`, the filesystem, subprocesses.

Rust already owned validation: capture compilation, overlap detection,
protected phrases, the catalog, and action validation. The built-in
transformations were already native.

## Decisions

- **Engine:** `rquickjs` 0.14 (QuickJS-ng 0.16.2), features `std` and
  `loader` only. It ships pregenerated bindings for every Opcode target (Linux
  x64/ARM64, macOS ARM64, Windows x64/ARM64), so builds need no bindgen.
- **One worker thread** owns the runtime. A load builds a fresh runtime and
  context, evaluates the config module graph once (QuickJS compiles it to
  bytecode at that point; calls never recompile), and keeps the handler and
  transformation functions until the next load replaces them. A fresh runtime
  per load means nothing from an old config survives a reload, and the
  memory limit applies per config. Loading takes about a third of a
  millisecond, so there is nothing to gain from caching bytecode on disk.
- **Limits:** an interrupt handler stops any call after 1 s and a load after
  2 s; the runtime is capped at 64 MiB and a 1 MiB JS stack.
- **No ambient authority:** the context has standard JavaScript only, plus a
  `console` that writes to Opcode's log. No filesystem, network, process,
  environment, or timers. Imports resolve to `@opcode/commands` or files inside
  the config folder (`.ts`, `.js`, `.mjs`, `.json`); anything else is refused.
- **Commands return actions.** A handler returns an action, a list, or
  nothing; `opcode.*` still exists and queues actions (resolving at once), so
  most existing handlers keep working. Opcode validates every action, then runs
  them in order on its native executor on a separate thread after the handler
  returns. The tool-call protocol, and with it the late-reply gap (#20), is
  gone.
- **Transformations** are `(text, context) => string`. A promise that settles
  without I/O is accepted, so `async` functions still work; nothing can wait
  on anything.
- **Language:** ES2023 modules as the baseline, and TypeScript by erasure.

### TypeScript: erase with oxc's parser

Measured on apollo (x86_64, stripped release binaries of a probe crate,
`rquickjs` alone vs. adding each option):

```text
rquickjs (QuickJS-ng)                  +1.30 MiB
oxc_parser + oxc_ast_visit (erasure)   +0.79 MiB
oxc_transformer + codegen + semantic   +2.63 MiB
```

Erasure parses with `oxc_parser` and overwrites every type-only span with
spaces (the `ts-blank-space` approach), so the JavaScript QuickJS runs has
the user's lines and columns and its errors point into their file without a
source map. It costs a third of the transformer's size and is faster
(about 6 µs for the starter config). It rejects only syntax that needs
generated code: enums, namespaces, constructor parameter properties, and
`import =`; the shipped `tsconfig.json` sets `erasableSyntaxOnly` so editors
flag the same things. JavaScript with JSDoc would save the 0.79 MiB, but
existing configs and the typed `defineOpcodeConfig` capture inference are
TypeScript, so erasure keeps them loading unchanged.

## What Changed For Users

- No install. `opcode commands init` (or Create Config / Set up) writes
  `opcode.config.ts` if missing, `tsconfig.json` if missing, and the Opcode-owned
  `opcode.d.ts` (types for `@opcode/commands`) and `AGENTS.md`.
- Existing `opcode.config.ts` files load as they are when they use only
  `@opcode/commands`, local files, and plain functions: the template, typed
  captures, `opcode.*` calls, and transformations all work.
- **Breaks:** Effect handlers (`@opcode/commands/effect`), npm packages,
  Node/Bun APIs (`fetch`, `fs`, `process`, timers), handlers that read an
  action's result or interleave work between actions, and TypeScript enums or
  namespaces. The old workspace files (`package.json`, `bun.lock`,
  `node_modules`, `.opcode-sdk`, `.agents`) are ignored and can be deleted.
- `opcode commands check` (macOS) loads the config as Opcode does and prints what it
  registers or why it fails, replacing `bun run check`.

## Measurements

apollo, Linux x86_64, release build, starter config plus a smart-punctuation
transformation (five regex replacements) over a 50-word dictation:

```text
binary (stripped)          47,038,240 -> 49,029,408 bytes  (+1.90 MiB, +4.2%)
config load                p50 0.33 ms, p99 0.82 ms   // runtime + context + erase + evaluate + compile registry
memory per loaded config   about 0.5 MiB RSS
transformation, in engine  p50 20 µs, p99 32 µs
transformation, via worker p50 24 µs, p99 40 µs      // what dictation sees
built-in transformation    p50 40 ns                  // native, unchanged
```

The Bun host it replaces, measured the same way on the same machine:

```text
host start to registration   87-98 ms (a child process)
host memory                  about 90 MiB RSS
transformation round trip    p50 23 µs, p99 209 µs   // stdin/stdout only, before Opcode's own queueing
```

QuickJS interprets where Bun's JIT compiles, so a regex-heavy transformation
takes about the same median time, with a far tighter tail and no process,
start-up delay, or tens of megabytes resident.

## Verification

- Tests in `personal_commands.rs` drive the worker with real scripts: the
  starter config, captures resolved from spoken text through the compiled
  registry, returned and queued actions, invalid actions, transformations
  with failures, time and memory limits, syntax and load errors with
  locations, reloads that keep the last good config, overlap rejection,
  stale generations, imports, and the absence of Node APIs. `typescript.rs`
  tests erasure and rejected syntax.
- Linux tests and clippy run on apollo; Windows x64 and ARM64 clippy through
  `cargo xwin` there; macOS through PR CI.
