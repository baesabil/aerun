import SwiftUI

// MARK: - PrimaryButton
// Tombol utama bergaya capsule — dipakai di onboarding dan halaman lain

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 300, height: 30)
                .padding()
                .background(isDestructive ? Color.red : Color.blue)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Next") { }
        PrimaryButton(title: "Delete", isDestructive: true) { }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}
