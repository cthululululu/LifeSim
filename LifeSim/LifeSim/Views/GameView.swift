import SwiftUI
import CoreData
import SpriteKit
import Combine

// Enumeration that defines each section of buttons
enum GameSection {
    case main, finances, job, relationships, education, assets, city, casino, blackjack, bank
}

struct GameView: View, Hashable {
    
    // Observes changes to PlayerData instance
    @ObservedObject var player: PlayerData
    // Initializes current game section to being in the main section
    @State private var currentSection: GameSection = .main
    
    @StateObject private var blackjackScene = BlackjackScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    @State private var betAmount: Int = 0
    

    
    
    var body: some View {
        VStack(spacing: 0) {
            
            ///#======= HEADER CONTENT CONTAINER ============
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Text("LifeSim")
                    .font(.custom("AvenirNext-Bold", size: 42))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding(.top)
            }
            .zIndex(1)
            .frame(height: UIScreen.main.bounds.height * 0.15)
            
            ///#======= SPRITEKIT CONTENT CONTAINER ============
            ZStack {
                VStack {
                    if currentSection == .blackjack {
                        SpriteView(scene: blackjackScene)
                            .onAppear {
                                blackjackScene.scaleMode = .resizeFill
                            }
                    } else {
                        SpriteView(scene: GameScene(size: CGSize(width: 300, height: 300), playerName: player.playerName ?? "Unknown", gender: player.gender ?? "Male"))
                    }

                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.40)
            
            ///#======= BUTTON NAVIGATION CONTAINER ============
            ZStack {
                Color.blue
                // Content Goes Here
                if currentSection == .main {
                    mainButtons()
                } else {
                    navigationButtons()
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.45)
        }
        // Disables navigation back to HomeView
        .navigationBarBackButtonHidden(true)
    }
    
    
    
    
    
    
    ///# ============= PROTOCOL CONFORMING =============

    // Conforms to Equatable Protocol
    static func == (lhs: GameView, rhs: GameView) -> Bool {
        return lhs.player.objectID == rhs.player.objectID
    }
    // Conforms to Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(player.objectID)
    }
    
    func savePlayerBalance(context: NSManagedObjectContext, player: PlayerData) {
        let fetchRequest: NSFetchRequest<PlayerData> = PlayerData.fetchRequest()
        
        do {
            let players = try context.fetch(fetchRequest)
            if let currentPlayer = players.first {
                currentPlayer.playerBalance = player.playerBalance
                
                // Save the context
                try context.save()
                print("Player balance saved: \(player.playerBalance)")
            } else {
                print("Player not found in Core Data")
            }
        } catch {
            print("Failed to fetch or save player: \(error.localizedDescription)")
        }
    }




    
    ///# ============= DEFINES BUTTON NAVIGATION =============
    func navigationButtons() -> some View {
        VStack {
            if currentSection == .finances {
                financeButtons()
            } else if currentSection == .job {
                careerButtons()
            } else if currentSection == .relationships {
                relationshipsButtons()
            } else if currentSection == .education {
                educationButtons()
            } else if currentSection == .assets {
                assetsButtons()
            } else if currentSection == .city {
                cityButtons()
            } else if currentSection == .casino {
                casinoButtons()
            } else if currentSection == .blackjack {
                blackjackButtons()
            } else if currentSection == .bank {
                bankButtons(player: player)
            }
        }
    }
    ///# ============= DEFINES MAIN BUTTON SET =============
    func mainButtons() -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: 20) {
            ForEach(["Career", "Finances", "Relationships", "Education", "Assets", "City"], id: \.self) { title in
                Button(action: {
                    switch title {
                    case "Career":
                        currentSection = .job
                    case "Finances":
                        currentSection = .finances
                    case "Relationships":
                        currentSection = .relationships
                    case "Education":
                        currentSection = .education
                    case "Assets":
                        currentSection = .assets
                    case "City":
                        currentSection = .city
                    default:
                        break
                    }
                }) {
                    Text(title)
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(Color.cyan)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .frame(maxWidth: .infinity) // Ensure the button spans the width
            }
        }
        .padding()
    }
    
    ///# ============= DEFINES FINANCE BUTTON SET =============
    func financeButtons() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 20) {
            Button(action: { currentSection = .main }) {
                Text("Back to Main")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { currentSection = .casino }) {
                Text("Go to Casino")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { currentSection = .bank }) {
                Text("Go to Bank")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    
    @State private var showLoanAlert = false
    @State private var loanMessage = ""
    @State private var loanAmount: Double = 0


    func determineLoanAmount(playerBalance: Double) {
        if playerBalance < 1000 {
            loanAmount = 500
            loanMessage = "You qualify for a loan of $500."
        } else if playerBalance >= 1000 && playerBalance < 40000 {
            loanAmount = 10000
            loanMessage = "You qualify for a loan of $10,000."
        } else if playerBalance >= 40000 {
            loanAmount = 35000
            loanMessage = "You qualify for a loan of $35,000."
        }
        showLoanAlert = true
    }

    func bankButtons(player: PlayerData) -> some View {
        let columns = [GridItem(.flexible())]
        return VStack {
            // Balance Display Container
            HStack {
                Text("Balance: $\(Int(player.playerBalance))")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding()
            }
            .frame(maxWidth: 300, minHeight: 30)
            .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // LazyVGrid for Bank Buttons
            LazyVGrid(columns: columns, spacing: 20) {
                Button(action: { currentSection = .finances }) {
                    Text("Back to Finances")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 250, minHeight: 80, maxHeight: 80)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                Button(action: { determineLoanAmount(playerBalance: player.playerBalance) }) {
                    Text("Apply for Loan")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 250, minHeight: 80, maxHeight: 80)
                        .background(Color.cyan)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .alert(isPresented: $showLoanAlert) {
                    Alert(
                        title: Text("Loan Application"),
                        message: Text(loanMessage),
                        primaryButton: .default(Text("Yes")) {
                            player.playerBalance += loanAmount
                            // Save the updated balance to Core Data
                            do {
                                try player.managedObjectContext?.save()
                            } catch {
                                print("Failed to save updated player balance: \(error)")
                            }
                        },
                        secondaryButton: .cancel(Text("No"))
                    )
                }
            }
        }
    }




    
    // Casino Button Set
    func casinoButtons() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 20) {
            Button(action: { currentSection = .finances }) {
                Text("Back to Finances")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            Button(action: {
                print("Play Blackjack")
                currentSection = .blackjack
            }) {
                Text("Play Blackjack")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    
    @State private var hitPressed: Bool = false
    @State private var hitDisabled: Bool = false
    @State private var backDisabled: Bool = false
    @State private var standDisabled: Bool = false
    @State private var betButtonsDisabled: Bool = false
    @State private var shouldUpdate: Bool = false
    @Environment(\.managedObjectContext) private var viewContext


    func blackjackButtons() -> some View {
        VStack(spacing: 20) {
            // Bet Display Container
            HStack {
                Text("Bet: \(betAmount)             Balance: \(Int(player.playerBalance))")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 30)
            .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
            .cornerRadius(10)
            .padding(.horizontal)

            // Increment and Cancel Buttons Container
            HStack(spacing: 20) {
                // 10 Button
                Button(action: { betAmount += 10 }) {
                    Text("10")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.black)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(radius: 10)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.cyan, lineWidth: 10)
                        )
                        .shadow(radius: 10)
                }
                .disabled(player.playerBalance < Double(betAmount + 10) || betButtonsDisabled)
                .opacity(player.playerBalance < Double(betAmount + 10) || betButtonsDisabled ? 0.5 : 1.0)

                // 50 Button
                Button(action: { betAmount += 50 }) {
                    Text("50")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.black)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(radius: 10)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.green, lineWidth: 10)
                        )
                        .shadow(radius: 10)
                }
                .disabled(player.playerBalance < Double(betAmount + 10) || betButtonsDisabled)
                .opacity(player.playerBalance < Double(betAmount + 10) || betButtonsDisabled ? 0.5 : 1.0)

                // 100 Button
                Button(action: { betAmount += 100 }) {
                    Text("100")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.black)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(radius: 10)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 10)
                            )
                        .shadow(radius: 10)
                }
                .disabled(player.playerBalance < Double(betAmount + 100) || betButtonsDisabled)
                .opacity(player.playerBalance < Double(betAmount + 100) || betButtonsDisabled ? 0.5 : 1.0)

                // Cancel Button
                Button(action: { betAmount = 0 }) {
                    Text("X")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(minWidth: 40, maxHeight: 40)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding(.horizontal)
            
            // Existing Buttons
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 20) {
                
                
                Button(action: {
                    
                    // Save the player's balance here
                    savePlayerBalance(context: viewContext, player: player)
                    currentSection = .casino
                }) {
                    Text("Back")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 150, minHeight: 50, maxHeight: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .disabled(backDisabled)
                .opacity(backDisabled ? 0.5 : 1.0)


                Button(action: {
                    var updateRequired = false
                    blackjackScene.hit(betAmount: betAmount, player: player, shouldUpdate: &updateRequired)
                    hitPressed = true
                    backDisabled = true
                    standDisabled = false
                    betButtonsDisabled = true

                    if updateRequired {
                        standDisabled = true
                        hitDisabled = true
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                            betButtonsDisabled = false
                            hitDisabled = false
                            backDisabled = false
                            betAmount = 0
                            updateRequired = false
                        }
                    }
                }) {
                    Text("Hit")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 150, minHeight: 50, maxHeight: 50)
                        .background(Color.cyan)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .disabled(betAmount == 0)
                .disabled(betAmount == 0 || hitDisabled)
                .opacity(betAmount == 0 || hitDisabled ? 0.5 : 1.0)

                Button(action: {
                    blackjackScene.stand(betAmount: betAmount, player: player)
                    betAmount = 0
                    standDisabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                        betButtonsDisabled = false
                        hitDisabled = false
                        backDisabled = false
                        
                    }
                }) {
                    Text("Stand")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 150, minHeight: 50, maxHeight: 50)
                        .background(Color.cyan)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .disabled(!hitPressed || standDisabled)
                .opacity(!hitPressed || standDisabled ? 0.5 : 1.0)
            }
        }
        .frame(maxHeight: .infinity)
    }





    
    ///# ============= DEFINES CAREER BUTTON SET =============
    func careerButtons() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 20) {
            Button(action: { currentSection = .main }) {
                Text("Back to Main")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Career Action 1") }) {
                Text("Career Action 1")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Career Action 2") }) {
                Text("Career Action 2")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    
    ///# ============= DEFINES RELATIONSHIPS BUTTON SET =============
    func relationshipsButtons() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 20) {
            Button(action: { currentSection = .main }) {
                Text("Back to Main")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Relationships Action 1") }) {
                Text("Relationships Action 1")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Relationships Action 2") }) {
                Text("Relationships Action 2")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    
    ///# ============= DEFINES EDUCATION BUTTON SET =============
    func educationButtons() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 20) {
            Button(action: { currentSection = .main }) {
                Text("Back to Main")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Education Action 1") }) {
                Text("Education Action 1")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Education Action 2") }) {
                Text("Education Action 2")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    
    ///# ============= DEFINES ASSETS BUTTON SET =============
    func assetsButtons() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 20) {
            Button(action: { currentSection = .main }) {
                Text("Back to Main")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Assets Action 1") }) {
                Text("Assets Action 1")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Assets Action 2") }) {
                Text("Assets Action 2")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    ///# ============= DEFINES CITY BUTTON SET =============
    func cityButtons() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 20) {
            Button(action: { currentSection = .main }) {
                Text("Back to Main")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("City Action 1") }) {
                Text("City Action 1")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("City Action 2") }) {
                Text("City Action 2")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
}///# ============= END OF BUTTON NAVIGATION =============




// Assuming GameView is the main view you want to preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Creating a sample PlayerData instance for preview purposes
        let newPlayer = PlayerData(context: context)
        newPlayer.playerName = "Jane"
        newPlayer.gender = "Female"
        newPlayer.playerBalance = 501
        newPlayer.saveDate = Date()
        
        return GameView(
            player: newPlayer
        )
            .environment(\.managedObjectContext, context)
    }
}
