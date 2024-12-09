import SwiftUI
import CoreData

struct GymView: View {
    
    let gymResult: [String] = ["Ran 10 Miles", "Did 20 Situps", "Did 50 bicep curles"]
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @ObservedObject var player: PlayerData
    let image = Image("gym")
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            Image(.gym)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            Text("Welcome to the Gym!")
                .font(.title)
                .padding()
            
            Text("Get fit and improve your health!")
            Text("This deacreases 10 Stress")
            Button(action: {
               
                guard player.playerBalance >= 30 else {
                    alertTitle = "Insufficient Balance"
                    alertMessage = "You need more money to go to the gym"
                    showAlert = true
                    return
                }
                
                player.stress = player.stress - 10 >= 0 ? player.stress - 10 : 0
                player.playerBalance = player.playerBalance - 30
                player.time -= 5
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
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
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
