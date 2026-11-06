import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct OpcodeDictationControl: ControlWidget {
    static let kind = "com.kitlangton.opcode.mobile.control.dictate"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: ToggleOpcodeControlIntent()) {
                Label("Dictate", systemImage: "mic.fill")
                Text("Opcode")
            }
        }
        .displayName("Dictate with Opcode")
        .description("Starts or finishes on-device dictation and copies the text.")
    }
}
