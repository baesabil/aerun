//
//  YoureAllSetView.swift
//  Aerun
//
//  Onboarding step terakhir — "You're All Set!" dengan progress bar.
//  Setelah animasi progress bar selesai (3 detik), otomatis pindah ke HomeView.
//
//  Light & Dark Mode: otomatis via Color(.systemBackground) dan .primary
//

import SwiftUI

struct YoureAllSetView: View {

    // Closure dari parent — dipanggil setelah animasi selesai → set hasSeenOnboarding = true
    let onFinish: () -> Void

    // Progress bar value: 0.0 → 1.0 selama 3 detik
    @State private var progress: Double = 0.0

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background adaptive
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // --- Checkmark icon ---
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green) // Hijau selalu — simbol "berhasil"
                    .padding(.bottom, 20)

                // --- Judul ---
                Text("You're All Set")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary) // Adaptive

                // --- Progress bar expandable ---
                // Animasi linear dari kiri ke kanan selama 3 detik
                CenterExpandingProgressBar(progress: progress)
                    .frame(width: 300, height: 5)
                    .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            startProgressAnimation()
        }
    }

    // MARK: - Animation Logic
    private func startProgressAnimation() {
        // withAnimation(.linear(duration:)) = animasi dengan kecepatan konstan
        // progress bergerak dari 0.0 ke 1.0 selama 3 detik
        withAnimation(.linear(duration: 3.0)) {
            progress = 1.0
        }

        // Setelah 3 detik (animasi selesai), panggil onFinish
        // → OnboardingContainerView akan set hasSeenOnboarding = true → HomeView
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                onFinish()
            }
        }
    }
}

// MARK: - CenterExpandingProgressBar
// Komponen progress bar kustom — bar mengisi dari kiri ke kanan
struct CenterExpandingProgressBar: View {

    let progress: Double // 0.0 – 1.0

    // Untuk menyesuaikan warna bar di light/dark mode
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Track background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.tertiarySystemFill)) // Adaptive: abu muda di light, abu gelap di dark

                // Bar yang mengisi — warna adaptive
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary) // Hitam di light, putih di dark
                    .frame(width: geometry.size.width * progress)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    YoureAllSetView {
        print("Move to Homepage")
    }
}
