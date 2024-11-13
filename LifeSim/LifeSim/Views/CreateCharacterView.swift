/**
    #CreateCharacterView.swift
 
    This view allows the player to input their player data and create
    a saved game based off that data. Navigates player to GameView
    after they have successfully created their player.
 */

import SwiftUI
import CoreData

struct CreateCharacterView: View, Hashable {
    @Binding var navigateToGame: Bool
    // Fetches CoreData context from environment
    @Environment(\.managedObjectContext) private var viewContext
    @State private var playerName: String = ""
    var startNewGame: (String) -> Void

    var body: some View {
        VStack {
            // Creates title for Character Creation
            Text("Create Your Character")
                .font(.largeTitle)
                .padding()
            
            // Text input for Player Name
            TextField("Player Name", text: $playerName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Start Game Button
            Button(action: {
                startNewGame(playerName)
                navigateToGame = true
            }) {
                Text("Start Game")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            // Disabled if not between 3-12 characters
            .disabled(playerName.count < 3 || playerName.count > 12)
        }
        // Navigation Title
        .navigationTitle("Create Character")
    }
    
    // Conforms to Equatable Protocol
    static func == (lhs: CreateCharacterView, rhs: CreateCharacterView) -> Bool {
        return lhs.navigateToGame == rhs.navigateToGame
    }
    // Conforms to Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(navigateToGame)
    }
}

// For XCode Preview Purposes only:
struct CreateCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return CreateCharacterView(navigateToGame: .constant(false), startNewGame: { _ in })
            .environment(\.managedObjectContext, context)
    }
}
