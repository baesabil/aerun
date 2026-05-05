import SwiftUI
import WatchKit
import Combine

struct CountdownView: View {
    @State private var countdownValue: Int = 3     // 3 → 2 → 1 → 0 (GO!)
    @State private var showGo: Bool = false
    @State private var navigateToWorkout: Bool = false
    @State private var opacity: Double = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 10) {
                if showGo {
                    Text("GO!")
                        .font(.system(size: 52, weight: .black))
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 0.2)) {
                                opacity = 1
                            }
                        }
                } else {
                    Text("\(countdownValue)")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .id(countdownValue)   // forces re-render on change
                        .transition(.opacity)
                }

                // Runner icon + label below the number
                HStack(spacing: 4) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 14))
                        .foregroundColor(.cyan)
                    Text("Outdoor Run")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .onAppear {
            opacity = 1
            // Haptic on appearance
            WKInterfaceDevice.current().play(.start)
        }
        .onReceive(timer) { _ in
            handleTick()
        }
        .navigationDestination(isPresented: $navigateToWorkout) {
            ActiveRunView()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
    }

    // MARK: - Tick logic
    private func handleTick() {
        if countdownValue > 1 {
            withAnimation(.easeOut(duration: 0.15)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                countdownValue -= 1
                WKInterfaceDevice.current().play(.click)
                withAnimation(.easeIn(duration: 0.25)) {
                    opacity = 1
                }
            }
        } else if countdownValue == 1 {
            withAnimation(.easeOut(duration: 0.15)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showGo = true
                WKInterfaceDevice.current().play(.success)
            }
            // Navigate to workout after GO! sits for 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                navigateToWorkout = true
            }
        }
    }
}
