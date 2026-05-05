import SwiftUI
import WatchKit

/// Placeholder workout screen — expanded in future sprint with live HR, elapsed time, pace.
struct ActiveRunView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.red)

                Text("Workout Started")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Feature coming soon")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Button("End Workout") {
                    WKInterfaceDevice.current().play(.stop)
                    // Pop all the way back to home
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
    }
}
