import type { Effect, Scope } from "effect"
import * as Opcode from "../src/index.js"
import * as EffectOpcode from "../src/effect.js"

// Compile-only consumer checks: never start a helper from a type assertion.
export function createTypes(
  low: Opcode.CreateOptions,
  ready: Opcode.TranscriberOptions,
  ambiguous: Omit<Opcode.CreateOptions, "model"> & { model?: Opcode.ModelId },
) {
  const host: Promise<Opcode.OpcodeHost> = Opcode.create(low)
  const transcriber: Promise<Opcode.Transcriber> = Opcode.create(ready)
  const effectHost: Effect.Effect<EffectOpcode.Host, EffectOpcode.OpcodeError, Scope.Scope> = EffectOpcode.create(low)
  const effectTranscriber: Effect.Effect<EffectOpcode.Transcriber, EffectOpcode.OpcodeError, Scope.Scope> = EffectOpcode.create(ready)
  const invalid = { model: "fictional-model" }

  // @ts-expect-error A model-bound transcriber cannot masquerade as a low-level host.
  const widened: Opcode.CreateOptions = ready
  // @ts-expect-error Optional models cannot determine which resource is returned.
  Opcode.create(ambiguous)
  // @ts-expect-error Optional models cannot determine which resource is returned.
  EffectOpcode.create(ambiguous)
  // @ts-expect-error Invalid model variables must not fall back to the low-level overload.
  Opcode.create(invalid)
  // @ts-expect-error Invalid model variables must not fall back to the low-level overload.
  EffectOpcode.create(invalid)
  // @ts-expect-error The existing service layer deliberately provides only the low-level client.
  EffectOpcode.layer(ready)

  return { host, transcriber, effectHost, effectTranscriber, widened }
}
