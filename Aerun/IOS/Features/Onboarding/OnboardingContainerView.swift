//
//  OnboardingContainerView.swift
//  Aerun
//
//  Created by Yuki Damanik on 02/05/26.
//

import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentStep = 0
    @State private var finishOnboarding = false
    
    var body: some View {
        
        if finishOnboarding {
            HomeView()
        } else {
            switch currentStep {
                
            case 0:
                GreetingView {
                    currentStep = 1
                }
                
            case 1:
                ConnectHealthView {
                    currentStep = 2
                }
                
            case 2:
                ConnectWatchView {
                    currentStep = 3
                }
                
            case 3:
                HapticExplanationView {
                    currentStep = 4
                }
                
            default:
                YoureAllSetView {
                    finishOnboarding = true
                }
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
}
