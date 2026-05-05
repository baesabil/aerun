//
//  ConnectHealthView.swift
//  Aerun
//
//  Onboarding step 1 — meminta izin akses HealthKit.
//  Saat user tap "Connect", app meminta izin baca data:
//  - Date of Birth (untuk hitung HRmax)
//  - Biological Sex (male/female → formula HRmax berbeda)
//  - Heart Rate & Resting Heart Rate (untuk zona HR)
//  - Workout data (untuk tampilkan history lari)
//
//  Light & Dark Mode: otomatis via Color(.systemBackground) dan .primary
//

import SwiftUI

struct ConnectHealthView: View {

    // Closure dari parent (OnboardingContainerView) — dipanggil setelah HealthKit granted
    let onConnect: () -> Void

    // Instance HealthKitService untuk request authorization
    // Private karena hanya dipakai di view ini
    private let healthKitService = HealthKitService()

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background adaptive — otomatis hitam/putih sesuai system theme
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // --- Icon Apple Health + label ---
                HStack {
                    // Pastikan image "AppleHealthIcon" ada di Assets.xcassets
                    Image("AppleHealthIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)

                    Text("Health")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary) // Adaptive: hitam di light, putih di dark
                        .padding(5)
                }

                // --- Deskripsi ---
                Text("Enable heart rate features by \n connecting to Apple Health")
                    .font(.body)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary) // Adaptive
                    .padding(.top, 24)

                Spacer()

                // --- Tombol Connect ---
                // Saat ditekan: request HealthKit authorization → lanjut ke step berikutnya
                Button {
                    healthKitService.requestAuthorization { success in
                        // Callback dari HealthKit — success bisa true/false
                        // Kita tetap lanjut ke step berikutnya apapun hasilnya
                        // karena user mungkin deny tapi tetap bisa pakai app (dengan default values)
                        print("HealthKit permission success: \(success)")
                        withAnimation {
                            onConnect()
                        }
                    }
                } label: {
                    Text("Connect")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white) // Tombol selalu putih di atas biru
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
    ConnectHealthView {
        print("Move to next onboarding screen")
    }
}
