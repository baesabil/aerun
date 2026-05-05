import SwiftUI

struct TryHapticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 4) { // jarak antar button

                // Take it easy — yellow, slow pulse
                NavigationLink(destination: HapticAnimationView(type: .takeItEasy)) {
                    HapticButtonRow(
                        label: "TAKE IT EASY",
                        color: .yellow,
                        icon: "play.circle.fill"
                    )
                }
                .buttonStyle(.plain)

                // Beware — orange, medium flash
                NavigationLink(destination: HapticAnimationView(type: .beware)) {
                    HapticButtonRow(
                        label: "BEWARE",
                        color: .orange,
                        icon: "play.circle.fill"
                    )
                }
                .buttonStyle(.plain)

                // Slow down — red, rapid flash
                NavigationLink(destination: HapticAnimationView(type: .slowDown)) {
                    HapticButtonRow(
                        label: "SLOW DOWN",
                        color: .red,
                        icon: "play.circle.fill"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 2) // padding kiri kanan
            .padding(.top, 8) // padding atas biar tidak mepet title
        }
        .background(Color.black) // background hitam
        .navigationTitle("Try Haptics") // title di kanan atas (inline)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable row button
private struct HapticButtonRow: View {
    let label: String  // teks tombol
    let color: Color   // warna background tombol
    let icon: String   // nama SF Symbol untuk icon kiri

    var body: some View {
        HStack(spacing: 10) {
            // icon play putih supaya kontras di atas warna tombol
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.white) // putih biar keliatan di atas yellow/orange/red

            // label teks tombol dengan SF Compact
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .fontDesign(.default)
                .foregroundColor(.black) // teks hitam kontras di atas warna terang

            Spacer() // dorong konten ke kiri
        }
        .padding(.horizontal, 12) // padding dalam tombol kiri-kanan
        .padding(.vertical, 12)   // padding dalam tombol atas-bawah
        .background(color)        // background warna sesuai tipe haptic
        .clipShape(RoundedRectangle(cornerRadius: 14)) // sudut rounded
    }
}

