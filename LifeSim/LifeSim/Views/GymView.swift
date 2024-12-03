import SwiftUI

struct GymView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Gym!")
                .font(.title)
                .padding()
            
            Text("Get fit and improve your health!")
        }
        .navigationTitle("Gym")
    }
}

#Preview {
    GymView()
}
