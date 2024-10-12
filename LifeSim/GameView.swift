/**
    #GameView.swift
 
    The main game UI where gameplay will take place.
    Currently serves no functionality besides displaying
    player's game save information.
 */

import SwiftUI
import CoreData

struct GameView: View, Hashable {
    
    // Observes changes to PlayerData instance
    @ObservedObject var player: PlayerData

    private var formattedSaveData: String {
        
        // If saved data exists
        if let playerName = player.playerName, let saveDate = player.saveDate {
            
            // Formats date and stores formatted date into formattedDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(from: saveDate)
            
            // Displays saved data
            return "Saved Game Data: \(playerName) on \(formattedDate)"
        } else {
            
            // No saved data to display
            return "No saved game data available"
        }
    }

    var body: some View {
        VStack {
            // Text displays formattedSaveData
            Text(formattedSaveData)
                .font(.largeTitle)
                .padding()
            
            // Main Game UI goes here
            
        }
        .navigationTitle("Main Game")
        // Navigation back currently disabled
        .navigationBarBackButtonHidden(true)
    }
    
    // Conforms to Equatable Protocol
    static func == (lhs: GameView, rhs: GameView) -> Bool {
        return lhs.player.objectID == rhs.player.objectID
    }
    // Conforms to Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(player.objectID)
    }
}

// For XCode Preview Purposes only:
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newPlayer = PlayerData(context: context)
        newPlayer.playerName = "Preview Player"
        newPlayer.saveDate = Date()

        return GameView(player: newPlayer)
            .environment(\.managedObjectContext, context)
    }
}
