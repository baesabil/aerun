//
//  OnboardingContainerView.swift
//  Aerun
//
//  Container utama yang mengatur alur onboarding step by step.
//  Menyimpan progress onboarding ke UserDefaults via @AppStorage
//  supaya kalau user sudah pernah onboarding, langsung ke HomeView.
//
//  Alur onboarding:
//  SplashView → GreetingView (step 0) → ConnectHealthView (step 1)
//  → ConnectWatchView (step 2) → HapticExplanationView (step 3)
//  → YoureAllSetView (step 4) → HomeView
//

import SwiftUI

struct OnboardingContainerView: View {

    // @State = state lokal yang hanya dimiliki view ini
    // currentStep melacak posisi user di alur onboarding
    @State private var currentStep = 0
    @State var isActive: Bool = false

    // @AppStorage = shortcut untuk UserDefaults — persisten di antara launch app
    // Key "hasSeenOnboarding" akan disimpan sebagai Bool di UserDefaults
    // true = user sudah selesai onboarding → langsung HomeView
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {

        if self.isActive {
            if hasSeenOnboarding {
                // User sudah pernah onboarding — langsung ke halaman utama
                HomeView()

            } else {
                // User baru — jalankan onboarding step by step
                // switch-case berdasarkan currentStep
                // Setiap view diberi closure onNext/onConnect untuk lanjut ke step berikutnya
                switch currentStep {

                case 0:
                    // Step 0: Sapaan + input nama user
                    GreetingView {
                        currentStep = 1  // Lanjut ke step 1 saat tombol "Next" ditekan
                    }

                case 1:
                    // Step 1: Minta izin HealthKit
                    ConnectHealthView {
                        currentStep = 2
                    }

                case 2:
                    // Step 2: Penjelasan tentang Apple Watch
                    ConnectWatchView {
                        currentStep = 3
                    }

                case 3:
                    // Step 3: Penjelasan fitur haptic
                    HapticExplanationView {
                        currentStep = 4
                    }

                default:
                    // Step 4 (default): "You're All Set!" — selesai onboarding
                    YoureAllSetView {
                        // Set flag onboarding selesai → @AppStorage otomatis simpan ke UserDefaults
                        hasSeenOnboarding = true
                        // Setelah ini, body akan re-evaluate dan karena hasSeenOnboarding = true
                        // → HomeView akan ditampilkan
                    }
                }
            }
        } else {
            // isActive = false → tampilkan SplashView
            // $isActive = Binding — SplashView bisa mengubah isActive dari sini
            SplashView(isActive: $isActive)
        }
    }
}

#Preview {
    OnboardingContainerView()
}
