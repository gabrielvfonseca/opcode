export type OpcodeErrorCode =
  | "startup-failed"
  | "startup-timeout"
  | "invalid-handshake"
  | "incompatible-api"
  | "service-exited"
  | "cancelled"
  | "request-failed"
  | "invalid-response"
  | "model-prepare-failed"
  | "shutdown-failed"

export class OpcodeError extends Error {
  readonly code: OpcodeErrorCode
  readonly status: number | undefined
  readonly remoteCode: string | undefined
  override readonly cause: unknown

  constructor(
    code: OpcodeErrorCode,
    message: string,
    options?: {
      readonly cause?: unknown
      readonly status?: number
      readonly remoteCode?: string
    },
  ) {
    super(message)
    this.name = "OpcodeError"
    this.code = code
    this.status = options?.status
    this.remoteCode = options?.remoteCode
    this.cause = options?.cause
  }
}

export const isOpcodeError = (value: unknown): value is OpcodeError => value instanceof OpcodeError
