import SwiftUI

// TODO: Implement ConnectWatchView

struct ConnectWatchView: View {
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(systemName: "applewatch")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                    .padding(.bottom, 32)
                
                Text("Watch")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Use Aerun with Apple Watch to monitor your heart rate, pace, distance, and time during runs.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 50)
                    .padding(.top, 12)
                
                Spacer()
                
                Button {
                    onNext()
                } label: {
                    Text("Continue")
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
}

#Preview {
    ConnectWatchView {
        print("Move to next onboarding screen")
    }
}
