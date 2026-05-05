//
//  HapticExplanationView.swift
//  Aerun
//
//  Onboarding step 3 — menjelaskan fitur haptic di Apple Watch.
//  Ada 2 sub-step (explanationStep 0 dan 1):
//  - Step 0: "Watch will vibrate softly when HR nearing danger"
//  - Step 1: "Watch will vibrate repeatedly when HR stays in danger zone"
//
//  Setelah kedua penjelasan selesai, lanjut ke YoureAllSetView.
//
//  Light & Dark Mode: otomatis via Color(.systemBackground) dan .primary
//

import SwiftUI

struct HapticExplanationView: View {

    // Closure dari parent — dipanggil setelah semua penjelasan selesai
    let onNext: () -> Void

    // Sub-step di dalam halaman ini: 0 = penjelasan pertama, 1 = penjelasan kedua
    // @State karena hanya relevan di view ini dan tidak perlu disimpan
    @State private var explanationStep = 0

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background adaptive
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // --- Icon ECG Waveform ---
                // SF Symbol ini menggambarkan detak jantung / fitur kesehatan
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 72))
                    .foregroundStyle(.primary) // Adaptive
                    .padding(.bottom, 32)

                // --- Teks penjelasan (berubah sesuai step) ---
                Text(descriptionText)
                    .font(.body)
                    .foregroundStyle(.primary) // Adaptive
                    .multilineTextAlignment(.center)

                Spacer()

                // --- Tombol (label berubah sesuai step) ---
                Button {
                    withAnimation {
                        handleButtonTap()
                    }
                } label: {
                    Text(buttonText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white) // Tetap putih di atas biru
                        .frame(width: 300, height: 30)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Computed Properties

    // Teks berubah tergantung step mana yang aktif
    private var descriptionText: String {
        if explanationStep == 0 {
            return "Apple Watch will vibrate softly \n to remind you to take easy, \n based on your heart rate"
        } else {
            return "Apple Watch will vibrate \n repeatedly when your heart rate \n stays too long in danger zone"
        }
    }

    // Label tombol: "Next" di step 0, "Got it" di step 1
    private var buttonText: String {
        explanationStep == 0 ? "Next" : "Got it"
    }

    // MARK: - Button Logic
    private func handleButtonTap() {
        if explanationStep == 0 {
            // Masih step pertama — lanjut ke step kedua
            explanationStep = 1
        } else {
            // Step kedua selesai — keluar dari HapticExplanationView
            withAnimation {
                onNext()
            }
        }
    }
}

#Preview {
    HapticExplanationView {
        print("Move to next onboarding screen")
    }
}
