import SwiftUI

struct YoureAllSetView: View {
    let onFinish: () -> Void
    
    @State private var progress: Double = 0.0
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)
                    .padding(.bottom, 20)
                
                Text("You're All Set")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                CenterExpandingProgressBar(progress: progress)
                    .frame(width: 300, height: 5)
                    .padding(.top, 20)
                
                Spacer()
            }
        }
        .onAppear {
            startProgressAnimation()
        }
    }
    
    private func startProgressAnimation() {
        withAnimation(.linear(duration: 3.0)) {
            progress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onFinish()
        }
    }
}

struct CenterExpandingProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: geometry.size.width * progress)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    YoureAllSetView {
        print("Move to Homepage")
    }
}
