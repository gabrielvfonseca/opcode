---
name: opcode-personal-commands
description: Configure Opcode personal deterministic transcript transformations in `~/.config/opcode/opcode.config.ts`. Use when the user wants to add or change custom text transformations for the Opcode voice app.
license: MIT
---

# Opcode Personal Transformations

This skill targets current Opcode (dev builds now, and the next stable release).
Opcode 2.3.1 uses an older runtime; its matching skill installs with
`npx skills add anomalyco/opcode#app-v2.3.1 --skill opcode-personal-commands`.

Opcode runs `~/.config/opcode/opcode.config.ts` itself, in an embedded JavaScript
engine. There is no package to install and no build step.

1. Check for `~/.config/opcode/opcode.config.ts` (or `opcode.config.js`). If it is
   missing, ask the user to open Opcode's Modes pane and choose Create Config,
   or run `opcode commands init` if the `opcode` CLI is available.
2. Read `~/.config/opcode/AGENTS.md` for the current API and limits, and
   `opcode.d.ts` for exact types. Opcode owns both and rewrites them; do not edit
   them.
3. Edit only the config and files it imports. Scripts are plain TypeScript or
   JavaScript: they can import `@opcode/commands` and files in the folder, not
   npm packages, Effect, or Node APIs, and they have no filesystem, network,
   or timer access. Enums, namespaces, and constructor parameter properties are
   rejected.
4. Use `defineOpcodeConfig` from `@opcode/commands` and declare pure `transformations`
   entries (`{ id, name, description?, transform(text, context) }`).
5. Transformations must be selected in the mode's Transformations section.
   They run after mode corrections and optional AI rewriting, not for meetings.
6. Run `opcode commands check` (macOS) after editing. It loads the config as Opcode
   does and prints what it registers or the error with file, line, and column.
   Optionally type-check with `npx -y -p typescript tsc` in `~/.config/opcode`. A
   running Opcode reloads the config on save and shows load errors in Modes'
   Transformations section.
   If `opcode` reports `commands check` as an unrecognized subcommand, stop: the
   user is on an older Opcode (such as 2.3.1). Tell them to install the matching
   skill with `npx skills add anomalyco/opcode#app-v2.3.1 --skill opcode-personal-commands`,
   or to switch to the dev build (https://github.com/anomalyco/opcode#downloads).

Completion criterion: the requested behavior is represented in the config,
`opcode commands check` succeeds (or, without the CLI, the reload succeeded in
Opcode), and any verification gap is reported.
