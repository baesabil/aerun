import SwiftUI

struct ConnectHealthView: View {
    let onConnect: () -> Void
    
    private let healthKitService = HealthKitService()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    Image("AppleHealthIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                    
                    Text("Health")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(5)
                    
                }
                
                Text("Enable heart rate features by \n connecting to Apple Health")
                    .font(.body)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.top, 24)
                
                Spacer()
                
                Button {
                    healthKitService.requestAuthorization { success in
                        print("HealthKit permission success: \(success)")
                        onConnect()
                    }
                } label: {
                    Text("Connect")
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
    ConnectHealthView {
        print("Move to next onboarding screen")
    }
}
