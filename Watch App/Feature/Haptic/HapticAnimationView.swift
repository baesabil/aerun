import SwiftUI
import WatchKit

// MARK: - Haptic type definition
enum HapticType {
    case takeItEasy
    case beware
    case slowDown

    var label: String {
        switch self {
        case .takeItEasy: return "TAKE IT EASY"
        case .beware:     return "BEWARE"
        case .slowDown:   return "SLOW DOWN"
        }
    }

    var color: Color {
        switch self {
        case .takeItEasy: return .yellow
        case .beware:     return .orange
        case .slowDown:   return Color(red: 0.95, green: 0.25, blue: 0.35)
        }
    }

    /// Duration of one ON flash in seconds
    var flashOnDuration: Double {
        switch self {
        case .takeItEasy: return 0.55   // slow pulse
        case .beware:     return 0.28   // medium
        case .slowDown:   return 0.14   // rapid
        }
    }

    /// Duration of one OFF flash
    var flashOffDuration: Double {
        switch self {
        case .takeItEasy: return 0.55
        case .beware:     return 0.22
        case .slowDown:   return 0.10
        }
    }

    /// Total number of flash cycles to play
    var flashCount: Int {
        switch self {
        case .takeItEasy: return 4
        case .beware:     return 6
        case .slowDown:   return 8
        }
    }

    /// WKHapticType to fire on each flash
    var hapticType: WKHapticType {
        switch self {
        case .takeItEasy: return .notification   // gentle double-tap
        case .beware:     return .directionUp    // distinct upward bump
        case .slowDown:   return .failure        // strong alert pattern
        }
    }
}

// MARK: - Animation View
struct HapticAnimationView: View {
    let type: HapticType

    @State private var isFlashOn: Bool = false
    @State private var isAnimating: Bool = false
    @State private var flashIndex: Int = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background flashes between color and black
            (isFlashOn ? type.color : Color.black)
                .ignoresSafeArea()
                .animation(.linear(duration: isFlashOn ? type.flashOnDuration : type.flashOffDuration), value: isFlashOn)

            VStack(spacing: 14) {
                Text(type.label)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(isFlashOn ? .black : type.color)
                    .multilineTextAlignment(.center)
                    .animation(.linear(duration: 0.05), value: isFlashOn)

                if !isAnimating {
                    Button("Try Again") {
                        startAnimation()
                    }
                    .buttonStyle(.bordered)
                    .tint(type.color)
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Animation engine
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        flashIndex = 0
        runNextFlash()
    }

    private func runNextFlash() {
        guard flashIndex < type.flashCount else {
            // Done — settle to black
            withAnimation(.linear(duration: 0.2)) {
                isFlashOn = false
            }
            isAnimating = false
            return
        }

        // Fire haptic on every flash ON
        WKInterfaceDevice.current().play(type.hapticType)

        // Turn ON
        withAnimation(.linear(duration: type.flashOnDuration)) {
            isFlashOn = true
        }

        // Schedule OFF after onDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + type.flashOnDuration) {
            withAnimation(.linear(duration: type.flashOffDuration)) {
                isFlashOn = false
            }
            flashIndex += 1
            // Schedule next flash after offDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + type.flashOffDuration) {
                runNextFlash()
            }
        }
    }
}
