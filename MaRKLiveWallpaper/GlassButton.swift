import SwiftUI

struct GlassButton: View {
    let label: String
    let systemImage: String
    var role: ButtonRole? = nil
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(role: role, action: action) {
            Label(label, systemImage: systemImage)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonBackgroundColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .opacity(isEnabled ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
    }
    
    private var buttonBackgroundColor: Color {
        if role == .destructive {
            return .red
        }
        return Color.accentColor
    }
}
