import SwiftUI
import CoreData

struct GymView: View {
    
    let gymResult: [String] = ["Ran 10 Miles", "Did 20 Situps", "Did 50 bicep curles"]
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @ObservedObject var player: PlayerData
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        // Fetches PlayerData entity
        entity: PlayerData.entity(),
        // Sorts instances of PlayerData by save date
        sortDescriptors: [NSSortDescriptor(keyPath: \PlayerData.saveDate, ascending: false)],
        animation: .default)
    // Fetched Results stored in variable `players`
    private var players: FetchedResults<PlayerData>
    
    var body: some View {
        VStack {
            Text("Welcome to the Gym!")
                .font(.title)
                .padding()
            
            Text("Get fit and improve your health!")
            Button(action: {
               /* guard let player = players.first else {
                    alertTitle = "No player found"
                    alertMessage = "Please Create a player before going to the Gym"
                    showAlert = true
                    return
                }*/
                guard player.playerBalance >= 30 else {
                    alertTitle = "Insufficient Balance"
                    alertMessage = "You need more money to go to the gym"
                    showAlert = true
                    return
                }
                
                player.stress = player.stress - 10 >= 0 ? player.stress - 10 : 0
                player.playerBalance = player.playerBalance - 30
                do {
                    try viewContext.save()
                    guard let gymResult = gymResult.randomElement() else {return}
                    
                    alertTitle = "Success"
                    alertMessage = gymResult
                    showAlert = true
                }
                catch {
                    
                }
                
                
            }, label: {
                Text("Go to Gym - $30")
            })
        }
        .alert(alertTitle, isPresented: $showAlert, actions: {
            Button(action: {
                
            }, label: {
                Text("Ok")
            })
        }, message: {
            Text(alertMessage)
        })
        .navigationTitle("Gym")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Creating a sample PlayerData instance for preview purposes
    let newPlayer = PlayerData(context: context)
    newPlayer.playerName = "Jane"
    newPlayer.gender = "Female"
    newPlayer.intelligence = 8
    newPlayer.playerBalance = 100
    newPlayer.saveDate = Date()
    newPlayer.hasLoan = false
    newPlayer.debt = 0
    newPlayer.hasStock = false
    newPlayer.stockBalance = 0
    
    
    return GymView(
        player: newPlayer
    )
        .environment(\.managedObjectContext, context)
}
