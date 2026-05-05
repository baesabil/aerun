import SwiftUI

// MARK: - App Color Tokens
// Semua warna yang dipakai di app didefinisikan di sini supaya konsisten

extension Color {

    // Brand
    static let aerunGreen    = Color(red: 0.18, green: 0.80, blue: 0.44)   // warna hijau utama
    static let aerunMint     = Color.mint

    // Backgrounds
    static let aerunBG       = Color.black                                  // background utama
    static let aerunCard     = Color.white.opacity(0.10)                    // card background
    static let aerunCardBorder = Color.white.opacity(0.20)                  // card border

    // HR Zone colors — urutan Zone 1–5
    static let zoneColors: [Color] = [.cyan, .green, .yellow, .orange, .red]

    // Text
    static let aerunPrimary  = Color.white
    static let aerunSecondary = Color.gray
}
