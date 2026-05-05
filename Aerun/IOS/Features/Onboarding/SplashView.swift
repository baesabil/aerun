//
//  SplashView.swift
//  Aerun
//
//  Layar splash yang muncul 2.5 detik saat app pertama dibuka.
//  Setelah delay, mengarahkan ke OnboardingContainerView.
//
//  Cara kerja:
//  1. SplashView muncul dengan logo "aeRUN♥"
//  2. Setelah 2.5 detik, @Binding isActive diset true
//  3. OnboardingContainerView mendeteksi isActive = true → tampilkan konten berikutnya
//

import SwiftUI

struct SplashView: View {

    // @Binding = referensi ke state yang dimiliki parent (OnboardingContainerView)
    // Mengubah isActive di sini akan otomatis mengubah state di parent
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            if self.isActive {
                // Setelah delay — OnboardingContainerView akan handle routing selanjutnya
                // Ini sebenarnya tidak akan terlihat karena parent langsung replace
                OnboardingContainerView()

            } else {
                // Layar splash utama
                // Pakai background warna mint yang mencolok sebagai brand identity
                Color.mint
                    .ignoresSafeArea()

                // Logo app
                Text("aeRUN♥")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.bottom, 93) // Sedikit di atas tengah layar
            }
        }
        .onAppear {
            // DispatchQueue.main.asyncAfter = jalankan kode setelah delay tertentu
            // deadline: .now() + 2.5 = 2.5 detik dari sekarang
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true  // Trigger transisi ke konten berikutnya
                }
            }
        }
    }
}
