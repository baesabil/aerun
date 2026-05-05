import SwiftUI
import Contacts

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
                .onAppear {
                    requestContactsInBackground()
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

    // MARK: - Contacts - silent background request
    private func requestContactsInBackground() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            guard granted else { return }
            let keys = [CNContactGivenNameKey as CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            try? store.enumerateContacts(with: request) { contact, stop in
                let firstName = contact.givenName
                if !firstName.isEmpty {
                    // Save to UserDefaults so HomeViewModel can read it
                    UserDefaults.standard.set(firstName, forKey: "aerun_user_name")
                    stop.pointee = true
                }
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
}
