import SwiftUI

// TODO: Implement HapticExplanationView

struct HapticExplanationView: View {
    let onNext: () -> Void
    
    @State private var explanationStep = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                    .padding(.bottom, 32)
                
                Text(descriptionText)
                    .font(.body)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    
                Spacer()
                
                Button {
                    handleButtonTap()
                } label: {
                    Text(buttonText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 300, height: 30)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var descriptionText: String {
        if explanationStep == 0 {
            return "Apple Watch will vibrate softly \n to remind you to take easy, \n based on your heart rate"
        } else {
            return "Apple Watch will vibrate \n repeatedly when your heart rate \n stays too long in danger zone"
        }
    }
    
    private var buttonText: String {
        if explanationStep == 0 {
            return "Next"
        } else {
            return "Got it"
        }
    }
    
    private func handleButtonTap() {
        if explanationStep == 0 {
            explanationStep = 1
        } else {
            onNext()
        }
    }
}

#Preview {
    HapticExplanationView {
        print("Move to next onboarding screen")
    }
}
