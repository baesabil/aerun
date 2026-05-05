//
//  ConnectWatchView.swift
//  Aerun
//
//  Onboarding step 2 — menjelaskan bahwa app bekerja dengan Apple Watch.
//  Halaman ini informatif saja (tidak ada permission request).
//
//  Light & Dark Mode: otomatis via Color(.systemBackground) dan .primary
//

import SwiftUI

struct ConnectWatchView: View {

    // Closure dari parent — dipanggil saat user tap "Continue"
    let onNext: () -> Void

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background adaptive — menyesuaikan system theme user
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // --- Icon Apple Watch ---
                // SF Symbol "applewatch" = ikon Apple Watch bawaan iOS
                Image(systemName: "applewatch")
                    .font(.system(size: 72))
                    .foregroundStyle(.primary) // Adaptive: hitam di light, putih di dark
                    .padding(.bottom, 32)

                // --- Judul ---
                Text("Watch")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary) // Adaptive

                // --- Deskripsi ---
                Text("Use Aerun with Apple Watch to monitor your heart rate, pace, distance, and time during runs.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary) // Abu — lebih muted dari primary
                    .padding(.horizontal, 50)
                    .padding(.top, 12)

                Spacer()

                // --- Tombol Continue ---
                Button {
                    withAnimation {
                        onNext()
                    }
                } label: {
                    Text("Continue")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white) // Tetap putih di atas background biru
                        .frame(width: 300, height: 30)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    ConnectWatchView {
        print("Move to next onboarding screen")
    }
}
