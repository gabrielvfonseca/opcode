import AppIntents
import Foundation

/// Shared between OpcodeMobile and OpcodeWidgets so Control Center, Lock Screen, and Action Button
/// controls can start or finish dictation in Opcode.
@available(iOS 18.0, *)
nonisolated struct ToggleOpcodeControlIntent: AppIntent {
    static let title: LocalizedStringResource = "Dictate with Opcode"
    static let description = IntentDescription("Starts or finishes on-device dictation and copies the transcript.")
    @available(iOS 26.0, *)
    static let supportedModes: IntentModes = .foreground
    static let isDiscoverable = false

    init() {}

    func perform() async throws -> some IntentResult {
        await OpcodeSystemCommandBus.shared.dispatch(.toggleDictation)
        return .result()
    }
}
