import SwiftUI

/// Unfinished features, off until turned on here. They live in the App Group so the
/// keyboard reads them too.
struct ExperimentsCard: View {
    @State private var fullKeyboard = FullKeyboardSettings().isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Experiments")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OpcodeTheme.textMuted)
                .padding(.leading, 16)

            Toggle(isOn: $fullKeyboard) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Full keyboard")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(OpcodeTheme.textBase)
                    Text("Type with Opcode, with an Opcode key to dictate")
                        .font(.system(size: 12))
                        .foregroundStyle(OpcodeTheme.textMuted)
                }
            }
            .tint(OpcodeTheme.success)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                OpcodeTheme.bgBase,
                in: RoundedRectangle(cornerRadius: OpcodeTheme.cardRadius, style: .continuous)
            )
            .onChange(of: fullKeyboard) { _, enabled in
                FullKeyboardSettings().isEnabled = enabled
            }
        }
        .onAppear {
            fullKeyboard = FullKeyboardSettings().isEnabled
        }
    }
}
