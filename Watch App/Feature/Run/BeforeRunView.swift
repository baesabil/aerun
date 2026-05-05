import SwiftUI

/// Shown when the user hasn't completed setup on iPhone yet.
struct BeforeRunView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 8) {
            Text("Requires iPhone")
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Please launch \"Aerun\" on iPhone to complete setup.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("OK") {
                // In a real app this dismisses or waits for WCSession notification.
                // For demo, tapping OK simulates setup complete.
                appState.markSetupComplete()
            }
            .buttonStyle(.bordered)
            .tint(.white)
            .padding(.top, 4)
        }
        .padding()
    }
}
