import SwiftUI
import CoreData
import SpriteKit




struct AssetView: View {
    @ObservedObject var player: PlayerData
    
    // Accessing the managed object context from the environment
    @Environment(\.managedObjectContext) private var viewContext
    

    var body: some View {
        VStack {
            ZStack {
                Color.red                    .ignoresSafeArea()
                Text("Player Data")
                    .font(.custom("AvenirNext-Bold", size: 42))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding(.top)
            }
            .zIndex(1)
            .frame(height: UIScreen.main.bounds.height * 0.15)
            VStack {
                SpriteView(scene: GameScene(size: CGSize(width: 300, height: 300), playerName: player.playerName ?? "Unknown", gender: player.gender ?? "Male"))
            }
            .frame(height: UIScreen.main.bounds.height * 0.40)
            ZStack {
                Color.blue
                VStack (alignment: .leading) {
                    HStack {
                        Text("Name: \(player.playerName ?? "Unknown")")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    
                    Text("Health: \(player.health)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    Text("Age: \(player.playerAge)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    Text("Balance: \(player.playerBalance)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Stress: \(player.stress)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    Text("Charisma: \(player.charisma)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    Text("Debt: \(player.debt)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    Text("Loan Intrest: \(player.loanInterest)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    Text("Has Stock: \(player.hasStock)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    Text("Stock Balance: \(player.stockBalance)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    Text("Inteligence: \(player.intelligence)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    
                    
                    Text("Luck: \(player.luck)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                    
                    
                    Text("Year: \(String(format: "%.0f", Double(2003 + player.playerAge) as Double))")                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    
                Spacer()

                }
            
                .padding()
            }
            .frame(height: UIScreen.main.bounds.height * 0.35)
            
        }
        
        .navigationTitle("Player Data")
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
            
            // Creating a sample PlayerData instance for preview purposes
            let newPlayer = PlayerData(context: context)
            newPlayer.playerName = "Jane"
            newPlayer.playerAge = 21
            newPlayer.health = 100
            newPlayer.gender = "Female"
            newPlayer.intelligence = 8
            newPlayer.playerBalance = 100
            newPlayer.saveDate = Date()
            newPlayer.hasLoan = false
            newPlayer.debt = 0
            newPlayer.hasStock = false
            newPlayer.stockBalance = 0
            
            
            return AssetView(
                player: newPlayer
            )
                .environment(\.managedObjectContext, context)
}
