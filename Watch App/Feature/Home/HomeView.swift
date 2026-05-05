import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    // Navigation destinations
    @State private var showHaptics = false
    @State private var showTimeGoal = false
    @State private var showCountdown = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Spacer()

                // Runner icon + label
                VStack(spacing: 6) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 36))
                        .foregroundColor(.cyan)

                    Text("Outdoor Run")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }

                Spacer()

                // Bottom action row
                HStack(spacing: 16) {
                    // Haptic warning button (left)
                    NavigationLink(destination: TryHapticsView()) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.18))
                                .frame(width: 35, height: 35)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.red.opacity(0.85))
                        }
                    }
                    .buttonStyle(.plain)

                    // Play button (center) — goes to countdown
                    NavigationLink(destination: CountdownView()) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 44, height: 44)
                            Image(systemName: "play.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(.plain)

                    // Timer / time goal button (right)
                    NavigationLink(destination: SetTimeGoalView()) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.18))
                                .frame(width: 35, height: 35)
                            Image(systemName: "timer")
                                .font(.system(size: 18))
                                .foregroundColor(.cyan)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }
}
