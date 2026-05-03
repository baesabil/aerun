import SwiftUI

// TODO: Implement HomeView

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Text("Home")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Your running dashboard will appear here")
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.top, 8)
            }
        }
    }
}

#Preview {
    HomeView()
}
