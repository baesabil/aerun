import SwiftUI

struct GreetingView: View {
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Hello!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("aeRUN♥")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundStyle(.mint)
                    .padding(.top, 24)
                
                Text("is here to help you \n start your running journey \n with less worry")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.top, 12)
                
                Spacer()
                
                Button {
                    onNext()
                } label: {
                    Text("Next")
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
    GreetingView {
        print("Next tapped")
    }
}
