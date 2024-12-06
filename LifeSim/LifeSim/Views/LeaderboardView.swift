import SwiftUI

struct LeaderboardView: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            
            // Linear Gradient Background Animation
            LinearGradient(colors: [Color(red: 18/255, green: 32/255, blue: 47/255), Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .hueRotation(.degrees(animateGradient ? 45 : 0))
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }

            VStack {
                // Leaderboard Title
                Text("Leaderboard")
                    .font(.custom("AvenirNext-Bold", size: 40))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()

                // Top 10 Player List
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(0..<10, id: \.self) { index in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.custom("AvenirNext-Regular", size: 24))
                                    .foregroundColor(Color.white)
                                    .frame(width: 40, alignment: .leading) // Adjusted width for numbers

                                Text("Player")
                                    .font(.custom("AvenirNext-Regular", size: 24))
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .frame(width: 250, alignment: .leading) // Fixed width for the player name
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}


struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
