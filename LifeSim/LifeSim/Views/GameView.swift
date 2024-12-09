import SwiftUI
import CoreData
import SpriteKit
import Combine

// Enumeration that defines each section of buttons
enum GameSection {
    case main, finances, job, relationships, education, assets, city, casino, blackjack, bank, loans, buy_stocks, entrance_exam, major, pay_tuition, final_exam, side_jobs, game_over
}

struct GameView: View, Hashable {
    
    // Observes changes to PlayerData instance
    @ObservedObject var player: PlayerData
    
    // Initializes current game section to being in the main section
    @State private var currentSection: GameSection = .main
    @State private var showPlayerData = false
    @StateObject private var blackjackScene = BlackjackScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    @State private var betAmount: Int = 0
    @State private var loanMessage: String = ""
    
    @State private var gameScene: GameScene
    init(player: PlayerData) {
        _gameScene = State(initialValue: GameScene(size: CGSize(width: 300, height: 300), playerName: player.playerName ?? "Unknown", gender: player.gender ?? "Male")); self.player = player
    }
    
   
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
                        SpriteView(scene: gameScene)
                    }
                }
                
            }
            .frame(height: UIScreen.main.bounds.height * 0.40)
            
            ///#======= BUTTON NAVIGATION CONTAINER ============
            ZStack {
                Color.blue
                // Content Goes Here
                if currentSection == .main {
                    mainButtons(player: player, currentSection: $currentSection)
                } else {
                    navigationButtons(currentSection: $currentSection, player: player)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.45)
        }
        .sheet(isPresented: $showPlayerData, content: {
            AssetView(player: player)
        })
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
                
                if(player.health <= 0){
                    currentSection = .game_over
                }
                
                // Checks if a Year has Passed of In Game Time
                if(player.time >= 100){
                    
                    // If player is in College and has not taken Finals
                    if(player.isEnrolled && !player.testTaken){
                        player.isTestTime = true
                        print("\nFinals Time!")
                        currentSection = .main
                        if(player.stockBalance > 0){
                            determineStock(player: player)
                        }
                        
                        
                    //  If player is in full time job and has not taken Raise test
                    } else if(player.isEmployed && !player.testTaken){
                        player.isTestTime = true
                        print("\nRaise Event Time!")
                        currentSection = .main
                        if(player.stockBalance > 0){
                            determineStock(player: player)
                        }
                        
                        
                    // Player is NOT Employed AND is NOT Enrolled in College
                    } else if(!player.isEmployed && !player.isEnrolled || player.isEnrolled && player.testTaken || player.isEmployed && player.testTaken){
                        
                        player.isTestTime = false
                        player.playerAge += 1;
                        // Update Health
                        // Update Stock
                        if(player.stockBalance > 0){
                            determineStock(player: player)
                        }
                        // Resets the Year
                        player.time -= 100;
                        calculateHealthDecrease()
                    }
                }
                
                
                currentPlayer.playerBalance = player.playerBalance
                currentPlayer.stockBalance = player.stockBalance
                currentPlayer.hasStock = player.hasStock
                currentPlayer.isEnrolled = player.isEnrolled
                currentPlayer.isGraduate = player.isGraduate
                currentPlayer.collegeMajor = player.collegeMajor
                currentPlayer.stress = player.stress
                currentPlayer.health = player.health
                currentPlayer.time = player.time
                currentPlayer.collegeDebt = player.collegeDebt
                currentPlayer.testTaken = player.testTaken
                currentPlayer.playerAge = player.playerAge
                currentPlayer.isTestTime = player.isTestTime
                currentPlayer.collegeYear = player.collegeYear
                
                
                // Save the context
                try context.save()
                print("\nPlayer balance saved: \(player.playerBalance)")
                print("Player stock balance saved: \(player.stockBalance)")
                print("Player hasStock saved: \(player.hasStock)")
                print("Player debt balance saved: \(player.debt)")
                print("Player isGraduate saved: \(player.isGraduate)")
                print("Player isEnrolled saved: \(player.isEnrolled)")
                print("Player Major saved: \(String(describing: player.collegeMajor))")
                print("Player Stress saved: \(player.stress)")
                print("Player Health saved: \(player.health)")
                print("Player Time saved: \(player.time)")
                print("Player College Debt saved: \(player.collegeDebt)")
                print("Player Age saved: \(player.playerAge)")
                print("Player testTaken saved: \(player.testTaken)")
                print("Player isTestTime saved: \(player.isTestTime)")
                print("Player College Year saved: \(player.collegeYear)")


                
            } else {
                print("Player not found in Core Data")
            }
        } catch {
            print("Failed to fetch or save player: \(error.localizedDescription)")
        }
    }




    
    ///# ============= DEFINES BUTTON NAVIGATION =============
    func navigationButtons(currentSection: Binding<GameSection>, player: PlayerData) -> some View {
        
        VStack {
            
            if currentSection.wrappedValue == .finances {
                financeButtons()
            } else if currentSection.wrappedValue  == .job {
                careerButtons()
            } else if currentSection.wrappedValue  == .relationships {
                relationshipsButtons()
            } else if currentSection.wrappedValue  == .education {
                educationButtons(player: player)
            } else if currentSection.wrappedValue  == .assets {
                assetsButtons()
            } else if currentSection.wrappedValue  == .city {
                cityButtons()
            } else if currentSection.wrappedValue  == .casino {
                casinoButtons()
            } else if currentSection.wrappedValue  == .blackjack {
                blackjackButtons()
            } else if currentSection.wrappedValue  == .bank {
                bankButtons(player: player)
            } else if currentSection.wrappedValue  == .loans {
                loanButtons(player: player)
            } else if currentSection.wrappedValue  == .buy_stocks {
                buyStockButtons(player: player)
            } else if currentSection.wrappedValue  == .entrance_exam {
                entranceExamButtons(player: player)
            } else if currentSection.wrappedValue  == .major {
                majorSelectionView(player: player)
            } else if currentSection.wrappedValue  == .pay_tuition {
                payTuitionSection(player: player)
            } else if currentSection.wrappedValue  == .final_exam {
                FinalExamView(currentSection: currentSection, player: player)
            } else if currentSection.wrappedValue == .side_jobs {
                sideJobSection()
            } else if currentSection.wrappedValue == .game_over {
                deathSection()
            }
                
        }
    }
    
    ///# ============= DEFINES MAIN BUTTON SET =============
    func mainButtons(player: PlayerData, currentSection: Binding<GameSection>) -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return LazyVGrid(columns: columns, spacing: 20) {
            ForEach(["Career", "Finances", "Relationships", "Education", "Assets", "City"], id: \.self) { title in
                // Determine if the button should be disabled based on the conditions
                let isDisabled: Bool = {
                    if title == "Relationships" {
                        return true
                    } else if player.isTestTime && player.isEnrolled {
                        return title == "Finances" || title == "Career" || title == "Assets" || title == "City"
                    } else if player.isTestTime && player.isEmployed {
                        return title == "Finances" || title == "Education" || title == "City"
                    } else {
                        return false
                    }
                }()

                Button(action: {
                    if player.isTestTime && player.isEnrolled {
                        // Navigate to final exam if it's test time and the player is enrolled
                        DispatchQueue.main.async {
                            currentSection.wrappedValue = .final_exam
                        }
                    } else if !isDisabled {
                        switch title {
                        case "Career":
                            currentSection.wrappedValue = .job
                        case "Finances":
                            currentSection.wrappedValue = .finances
                        case "Relationships":
                            currentSection.wrappedValue = .relationships
                        case "Education":
                            currentSection.wrappedValue = .education
                        case "Assets":
                            currentSection.wrappedValue = .assets
                        case "City":
                            currentSection.wrappedValue = .city
                        default:
                            break
                        }
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
                        .opacity(isDisabled ? 0.5 : 1.0) // Set opacity based on disabled state
                }
                .disabled(isDisabled)
                .frame(maxWidth: .infinity) // Ensure the button spans the width
            }
        }
        .padding()
        .onAppear(){
            if(!player.isTestTime){
                savePlayerBalance(context: viewContext, player: player)
            }
        }
    }

    
    ///# =====================================================
    ///# ============= DEFINES FINANCE BUTTON SET ============
    ///# =====================================================
    
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
            Button(action: { currentSection = .buy_stocks }) {
                Text("Invest")
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
    @State private var loanAmount: Double = 0
    @State private var interestRate: Double = 0

    func determineLoanAmount(playerBalance: Double) {
        if playerBalance < 1000 {
            loanAmount = 500
            interestRate = 0.12
        } else if playerBalance >= 1000 && playerBalance < 5000 {
            loanAmount = playerBalance * 3
            interestRate = 0.10
        } else if playerBalance >= 5000 && playerBalance < 20000 {
            loanAmount = playerBalance * 2.5
            interestRate = 0.08
        } else if playerBalance >= 20000 && playerBalance < 50000 {
            loanAmount = playerBalance * 2
            interestRate = 0.07
        } else if playerBalance >= 50000 {
            loanAmount = playerBalance * 1.5
            interestRate = 0.06
        }
        showLoanAlert = true
    }



    func bankButtons(player: PlayerData) -> some View {
        let columns = [GridItem(.flexible())]
        return VStack {
            // Balance Display Container
            HStack {
                Text("Balance: $\(String(format: "%.2f", player.playerBalance))")                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding()
            }
            .frame(maxWidth: 250, minHeight: 30)
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
                Button(action: { determineLoanAmount(playerBalance: player.playerBalance)
                    if player.hasLoan {
                        loanMessage = "Ready to pay your $\(Int(player.debt).formatted()) debt?"
                    } else {
                        loanMessage = "You qualify for a loan of $\(Int(loanAmount).formatted()). Would you like to claim it?\nReturn in 12 months\nInterest Rate: \(Int(interestRate * 100))%"
                    }

                    currentSection = .loans
                }) {
                    Text("Bank Loan")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 250, minHeight: 80, maxHeight: 80)
                        .background(Color.cyan)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        }
    }

    @State private var disableLoanButtons: Bool = false

    func loanButtons(player: PlayerData) -> some View {
        
        return VStack(spacing: 20) {
            HStack {
                Text(loanMessage)
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding()
            }
            .frame(maxWidth: 400, minHeight: 200, maxHeight:200)
            .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
            .cornerRadius(10)
            .padding(.horizontal)

            // HStack for Loan Buttons
            HStack(spacing: 65) { // Add spacing between buttons
                Button(action: {
                    
                    loanMessage = "Thank you for coming! Hope to see you again."
                    disableLoanButtons = true
                    if(player.hasLoan && player.debt <= player.playerBalance){
                        // Player has loan and can pay it off
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            disableLoanButtons = false
                            player.playerBalance -= player.debt
                            player.loanInterest = 0
                            player.debt = 0
                            player.hasLoan = false
                            savePlayerBalance(context: viewContext, player: player)
                            currentSection = .bank
                        }
                    } else if(player.hasLoan && player.debt > player.playerBalance) {
                        // Player has loan but does not have enough money to pay if off
                        loanMessage = "You do not have sufficient funds. Please come again later"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            disableLoanButtons = false
                            currentSection = .bank
                        }
                    } else if(!player.hasLoan){
                        // Player does not have loan and accepts loan
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            disableLoanButtons = false
                            player.loanInterest = interestRate
                            player.debt += loanAmount
                            player.playerBalance += loanAmount
                            player.hasLoan = true
                            savePlayerBalance(context: viewContext, player: player)
                            currentSection = .bank
                        }
                    }
                }) {
                    Text("Yes")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                        .background(Color.green)
                        .opacity(disableLoanButtons ? 0.5 : 1)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .disabled(disableLoanButtons)
                
                Button(action: {
                    currentSection = .bank
                }) {
                    Text("No")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                        .background(Color.red)
                        .opacity(disableLoanButtons ? 0.5 : 1)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .disabled(disableLoanButtons)
                
            }
        }
    }
        
    @State var percentageChange: Double = 0

    func determineStock(player: PlayerData) {
        var successRate: Double
        
        switch player.intelligence {
        case 10:
            successRate = 0.90 // Max Success Rate
        case 7...9:
            successRate = 0.8 // High Success Rate
        case 4...6:
            successRate = 0.70 // Moderate Success Rate
        case 1...3:
            successRate = 0.45 // Low Success Rate
        default:
            successRate = 0.0
        }
        print("Success Rate: \(successRate)")
        
        let randomOutcome = Double.random(in: 0...1)
        
        if randomOutcome < successRate {
            percentageChange = Double.random(in: 0.01...0.10) // Random increase of 1% to 10%
            player.stockBalance *= (1 + percentageChange)
        } else {
            percentageChange = -Double.random(in: 0.01...0.10) // Random decrease of 1% to 10%
            player.stockBalance *= (1 + percentageChange)
        }
        
        let displayPercentageChange = percentageChange * 100
        print("Percentage Change: \(displayPercentageChange)%")
        print("New Stock Balance: \(player.stockBalance)")
    }



    @State private var stockAmount: Double = 0
    func buyStockButtons(player: PlayerData) -> some View {
        var chosenStock: String
        var stockMessage: String
        
        switch player.intelligence {
        case 10:
            chosenStock = "AAPL"
            stockMessage = "You have decided to invest in Apple! This tech giant will not let you down."
        case 7...9:
            chosenStock = "TSLA"
            stockMessage = "You have decided to invest in Tesla! You have put your faith in the future of EVs."
        case 4...6:
            chosenStock = "BTC"
            stockMessage = "You have decided to invest in Bitcoin! You fully believe in the pioneer of cryptocurrency."
        case 1...3:
            chosenStock = "DOGE"
            stockMessage = "You have decided to invest in DOGE coin! You are willing to risk it all for the meme!"
        default:
            chosenStock = "N/A"
            stockMessage = "No valid stock."
        }
        
        return VStack(spacing: 20) {
            if player.hasStock {
                VStack {
                    VStack {
                        HStack {
                            Text(chosenStock)
                                .font(.custom("AvenirNext-Bold", size: 24))
                                .foregroundColor(Color.white)
                            if (percentageChange > 0) {
                                Text("(\(String(format: "%.2f", percentageChange * 100))%)")
                                    .font(.custom("AvenirNext-Bold", size: 18))
                                    .foregroundColor(Color.green)
                            } else {
                                Text("(\(String(format: "%.2f", percentageChange * 100))%)")
                                    .font(.custom("AvenirNext-Bold", size: 18))
                                    .foregroundColor(Color.red)
                            }

                            
                        }
                        Text("Investment: $\(String(format: "%.2f", player.stockBalance))")
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .foregroundColor(Color.white)
                        
                        Text("\(stockMessage)")
                            .font(.custom("AvenirNext-Bold", size: 18))
                            .foregroundColor(Color.white)
                            .padding()
                    }
                    .frame(minWidth: 350, maxWidth: 350, minHeight: 200, maxHeight: 200)
                    .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                    .cornerRadius(10)
                    
                    
                    HStack {
                        Button(action: {
                            // Action to navigate back to finances
                            currentSection = .finances
                        }) {
                            Text("Hold")
                                .font(.custom("AvenirNext-Bold", size: 22))
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        }
                        .frame(maxWidth: 100, minHeight: 60, maxHeight: 60)
                        
                        Button(action: {
                            player.playerBalance += player.stockBalance
                            player.stockBalance = 0
                            player.hasStock = false
                            savePlayerBalance(context: viewContext, player: player)
                        }) {
                            Text("Sell")
                                .font(.custom("AvenirNext-Bold", size: 22))
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        }
                        .frame(minWidth: 100, minHeight: 60, maxHeight: 60)
                    }
                }
            } else {
                HStack {
                    Text("Invest")
                        .font(.custom("AvenirNext-Bold", size: 28))
                        .foregroundColor(Color.white)
                        .shadow(radius: 10)
                }
                HStack {
                    Text("Balance: $\(String(format: "%.2f", player.playerBalance))")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                }
                .frame(minWidth: 350, maxWidth: 350, minHeight: 70)
                .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                .cornerRadius(10)
                
                // Amount Selection
                HStack {
                    Button(action: {
                        // Decrease stock amount, only reduce from 100 to 0
                        if stockAmount == 100 {
                            stockAmount = 0
                        } else {
                            stockAmount /= 10
                        }
                    }) {
                        Text("<")
                            .font(.custom("AvenirNext-Bold", size: 32))
                            .shadow(radius: 5)
                            .padding()
                            .foregroundColor(stockAmount == 0 ? Color.white.opacity(0.5) : Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(stockAmount == 0)
                    
                    Text("$\(Int(stockAmount))")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 24)  // Adjust padding to ensure centering
                        .frame(minWidth: 50, alignment: .center)  // Ensure minimum width for centering
                    
                    Button(action: {
                        // Increase stock amount
                        if stockAmount == 0 {
                            stockAmount = 100
                        } else {
                            stockAmount = min(stockAmount * 10, 1_000_000)
                        }
                    }) {
                        Text(">")
                            .font(.custom("AvenirNext-Bold", size: 32))
                            .shadow(radius: 5)
                            .padding()
                            .foregroundColor(((stockAmount == 0 ? 100 : stockAmount * 10) > player.playerBalance || stockAmount >= 1_000_000) ? Color.gray.opacity(0.5) : Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled((stockAmount == 0 ? 100 : stockAmount * 10) > player.playerBalance || stockAmount >= 1_000_000)
                }
                .frame(minWidth: 350, maxWidth: 350, minHeight: 75)
                .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                .cornerRadius(10)
                .padding(.horizontal)

                // LazyVGrid for Buttons
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    // Back Button
                    Button(action: {
                        // Action to navigate back to finances
                        currentSection = .finances
                        stockAmount = 0
                    }) {
                        Text("Back")
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                            .padding()
                            .frame(maxWidth: 150, minHeight: 60, maxHeight: 60)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    
                    // Buy Stocks Button
                    Button(action: {
                        // Action to buy stocks
                        player.stockBalance += stockAmount
                        player.playerBalance -= stockAmount
                        player.hasStock = true
                        savePlayerBalance(context: viewContext, player: player)
                    }) {
                        Text("Invest")
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .shadow(radius: 5)
                            .padding()
                            .frame(maxWidth: 150, minHeight: 60, maxHeight: 60)
                            .background((stockAmount == 0 || stockAmount > player.playerBalance) ? Color.cyan.opacity(0.5) : Color.cyan)
                            .foregroundColor((stockAmount == 0 || stockAmount > player.playerBalance) ? Color.white.opacity(0.5) : Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .disabled(stockAmount == 0 || stockAmount > player.playerBalance)
                    
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
                .disabled(player.playerBalance < Double(betAmount + 50) || betButtonsDisabled)
                .opacity(player.playerBalance < Double(betAmount + 50) || betButtonsDisabled ? 0.5 : 1.0)

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
            
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 20) {
                
                Button(action: {
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
                        savePlayerBalance(context: viewContext, player: player)
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
    
    ///# ====================================================================
    ///# ==================== DEFINES CAREER ACTION SET =====================
    ///# ====================================================================

    func careerButtons() -> some View {
        VStack(spacing: 20) {
            Button(action: { currentSection = .main }) {
                Text("Back to Main")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            Button(action: {
                currentSection = .side_jobs
            }) {
                Text("Side Jobs")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            Button(action: { print("Full-Time Jobs Action") }) {
                Text("Full-Time Jobs")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .opacity(0.5)
            }
            .disabled(true)
        }
        .padding()
    }
    @State private var showAlert = false
    @State private var tipAmount = 0.0
    func sideJobSection() -> some View {

        return VStack(spacing: 20) {
            Button(action: { currentSection = .job }) {
                Text("Back to Career")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }

            Button(action: {
                tipAmount = 1000 * (Double(player.luck) / 100)
                player.playerBalance += (1000 + tipAmount)
                player.time += 5
                savePlayerBalance(context: viewContext, player: player)
                showAlert = true
            }) {
                Text("Uber Driver")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Uber Driver"), message: Text("You made $\(Int(tipAmount)) in Tips!"), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }


    ///# ====================================================================
    ///# ==================== DEFINES RELATIONSHIP ACTION SET ===============
    ///# ====================================================================
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
    
    ///# ====================================================================
    ///# ================ ``DEFINES EDUCATION ACTION SET`` ==================
    ///# ====================================================================

    func educationButtons(player: PlayerData) -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        
        return Group {
            if !player.isGraduate && !player.isEnrolled {
                VStack(spacing: 20) {
                    // Back to Main button
                    Button(action: { currentSection = .main }) {
                        Text("Back to Main")
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                            .padding()
                            .frame(maxWidth: 250, minHeight: 80, maxHeight: 80)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    
                    // Apply to College button
                    Button(action: {
                        currentSection = .entrance_exam
                        print("Apply to College Action")
                    }) {
                        Text("Apply to College")
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                            .padding()
                            .frame(maxWidth: 250, minHeight: 80, maxHeight: 80)
                            .background(Color.cyan)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    // Conditional Message based on player state
                    VStack(alignment: .leading) {
                        if player.isGraduate {
                            Text("Congratulations, you have already received your Diploma in \(player.collegeMajor ?? "").")
                        } else if player.isEnrolled {
                            Text("You are currently in Year \(player.collegeYear) of College! You chose to study \(player.collegeMajor ?? "").")
                        }
                    }
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        // Back to Main button
                        Button(action: { currentSection = .main }) {
                            Text("Back to Main")
                                .font(.custom("AvenirNext-Bold", size: 22))
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                .background(Color.red)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        
                        // Conditional buttons based on player state
                        if player.isEnrolled {
                            Button(action: {
                                player.stress -= 2
                                player.time += 5
                                savePlayerBalance(context: viewContext, player: player)
                            }) {
                                Text("Study Hard")
                                    .font(.custom("AvenirNext-Bold", size: 22))
                                    .foregroundColor(Color.white)
                                    .shadow(radius: 5)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                    .background(Color.cyan)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }

                            Button(action: {
                                currentSection = .pay_tuition
                            }) {
                                Text("Pay Tuition")
                                    .font(.custom("AvenirNext-Bold", size: 22))
                                    .foregroundColor(Color.white)
                                    .shadow(radius: 5)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                    .background(Color.cyan)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }

                        // Pay Tuition button for graduates
                        if player.isGraduate {
                            Button(action: { currentSection = .pay_tuition }) {
                                Text("Pay Tuition")
                                    .font(.custom("AvenirNext-Bold", size: 22))
                                    .foregroundColor(Color.white)
                                    .shadow(radius: 5)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                    .background(Color.cyan)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                    }
                }
            }
        }
    }


    func payTuitionSection(player: PlayerData) -> some View {
        let message = player.collegeDebt == 0 ? "You have paid for your Tuition. Thank you!" : "Would you like to pay $10,000 towards your tuition?"
        let isPayDisabled = player.collegeDebt == 0 || player.playerBalance < 10000

        return VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text(message)
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding(.bottom, 5)
                Text("Debt: $\(Int(player.collegeDebt))")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                Text("Balance: $\(String(format: "%.2f", player.playerBalance))")                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding(.bottom, 5)
            }
            .frame(maxWidth: 400, minHeight: 200, maxHeight: 200)
            .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Pay and Back Buttons
            HStack(spacing: 65) {
                Button(action: {
                    if !isPayDisabled {
                        // max() ensures that collegeDebt does not become negative
                        player.collegeDebt = max(0, player.collegeDebt - 10000)
                        player.playerBalance -= 10000
                        savePlayerBalance(context: viewContext, player: player)
                    }
                }) {
                    Text("Pay")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .opacity(isPayDisabled ? 0.5 : 1.0)
                }
                .disabled(isPayDisabled)
                .frame(maxWidth: .infinity)
                
                Button(action: { currentSection = .education }) {
                    Text("Back")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    @State private var entranceExamTracker = 0
    @State private var entranceExamGrade = 0
    @State private var disableButtons = false
    @State private var examMessage = """
    Would you like to take your entrance exam?
    
    Fee: $250
    Full Tuition: $80,000
    """
    
    func entranceExamButtons(player: PlayerData) -> some View {
        // First Item: Question, Second Item: Correct Ans, Third Item: Incorrect Ans
        let questions = [
            ("What is 5 + 2 x (6 - 4)", "9", "14"),
            ("What year was the US Revolutionary War?", "1775", "1812"),
            ("What is the largest planet in our Solar System?", "Jupiter", "Mars")
        ]
        
        return VStack(spacing: 20) {
            Text(examMessage)
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundColor(Color.white)
                .padding()
                .frame(maxWidth: 400, minHeight: 200, maxHeight: 200)
                .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                .cornerRadius(10)
                .padding(.horizontal)
            
            HStack(spacing: 65) {
                if entranceExamTracker == 0 {
                    Button(action: {
                        disableButtons = true
                        if player.playerBalance >= 250 {
                            examMessage = "Good Luck!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                disableButtons = false
                                entranceExamTracker = 1
                                examMessage = questions[entranceExamTracker - 1].0
                                player.playerBalance -= 250
                            }
                        } else {
                            examMessage = "Insufficient balance. You need at least $250 to take the exam."
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                disableButtons = false
                                currentSection = .education
                                examMessage = """
                                Would you like to take your entrance exam?
                                
                                Fee: $250
                                Full Tuition: $80,000
                                """
                            }
                        }
                    }) {
                        Text(disableButtons ? "" : "Yes")
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                            .padding()
                            .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                            .background(disableButtons ? Color.gray : Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(disableButtons)
                    
                    Button(action: {
                        currentSection = .education
                    }) {
                        Text(disableButtons ? "" : "No")
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                            .padding()
                            .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                            .background(disableButtons ? Color.gray : Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(disableButtons)
                } else {
                    examQuestionButtons(player: player, entranceExamTracker: $entranceExamTracker, entranceExamGrade: $entranceExamGrade, disableButtons: $disableButtons, examMessage: $examMessage, questions: questions)
                }
            }
        }
    }

    private func examQuestionButtons(player: PlayerData, entranceExamTracker: Binding<Int>, entranceExamGrade: Binding<Int>, disableButtons: Binding<Bool>, examMessage: Binding<String>, questions: [(String, String, String)]) -> some View {
        let currentQuestion = questions[entranceExamTracker.wrappedValue - 1]
        let answers = [(currentQuestion.1, true), (currentQuestion.2, false)].shuffled()
        
        return HStack(spacing: 65) {
            ForEach(answers, id: \.0) { answer in
                Button(action: {
                    answerEntranceQuestion(correct: answer.1, player: player, entranceExamTracker: entranceExamTracker, entranceExamGrade: entranceExamGrade, disableButtons: disableButtons, examMessage: examMessage, questions: questions)
                }) {
                    Text(disableButtons.wrappedValue ? "" : answer.0)
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                        .background(disableButtons.wrappedValue ? Color.gray : Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .disabled(disableButtons.wrappedValue)
            }
        }
    }

    private func answerEntranceQuestion(correct: Bool, player: PlayerData, entranceExamTracker: Binding<Int>, entranceExamGrade: Binding<Int>, disableButtons: Binding<Bool>, examMessage: Binding<String>, questions: [(String, String, String)]) {
        disableButtons.wrappedValue = true
        
        // Display "Correct!" or "Wrong!" immediately
        examMessage.wrappedValue = correct ? "Correct!" : "Wrong!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if correct {
                entranceExamGrade.wrappedValue += 1
            }

            entranceExamTracker.wrappedValue += 1

            if entranceExamTracker.wrappedValue > 3 {
                examMessage.wrappedValue = entranceExamGrade.wrappedValue >= 2 ? "You passed the exam!" : "You failed the exam."
                if entranceExamGrade.wrappedValue >= 2 {
                    player.isEnrolled = true
                }
                entranceExamTracker.wrappedValue = 0 // Reset for next interaction

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if entranceExamGrade.wrappedValue >= 2 {
                        examMessage.wrappedValue = "Choose a Major"
                        currentSection = .major
                    } else {
                        // Reset state for retrying the exam
                        entranceExamTracker.wrappedValue = 0
                        entranceExamGrade.wrappedValue = 0
                        disableButtons.wrappedValue = false
                        examMessage.wrappedValue = """
                        Would you like to take your entrance exam?

                        Fee: $250
                        Full Tuition: $80,000
                        """
                        currentSection = .education
                    }
                }
            } else {
                examMessage.wrappedValue = questions[entranceExamTracker.wrappedValue - 1].0
                disableButtons.wrappedValue = false
            }
        }
    }

    private func majorSelectionView(player: PlayerData) -> some View {
        
        VStack(spacing: 20) {
            Text(examMessage)
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundColor(Color.white)
                .shadow(radius: 5)
                .padding()
                .frame(maxWidth: 300, minHeight: 100, maxHeight: 100)
                .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                .cornerRadius(10)
                .shadow(radius: 5)

            VStack(spacing: 20) {
                Button(action: {
                    player.collegeMajor = "Comp Sci"
                    finalizeMajorSelection(player: player)
                }) {
                    Text("Comp Sci")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 300, minHeight: 60, maxHeight: 60)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }

                Button(action: {
                    player.collegeMajor = "History"
                    finalizeMajorSelection(player: player)
                }) {
                    Text("History")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 300, minHeight: 60, maxHeight: 60)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }

                Button(action: {
                    player.collegeMajor = "Biology"
                    finalizeMajorSelection(player: player)
                }) {
                    Text("Biology")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 300, minHeight: 60, maxHeight: 60)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        }
    }
    
    private func finalizeMajorSelection(player: PlayerData) {
        disableButtons = true
        examMessage = "You are now studying \(player.collegeMajor ?? "")"

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            player.isEnrolled = true
            player.time += 60
            player.collegeDebt += 80000
            player.stress += 80
            
            savePlayerBalance(context: viewContext, player: player)
            disableButtons = false
            currentSection = .education
        }
    }
    
    
    
    ///# ====================================================================
    ///# ==================== ASSETS SECTION DISPLAYS PLAYERDATA ============
    ///# ====================================================================
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
            Button(action: {
             showPlayerData = true
            }) {
                Text("Player Data")
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
    ///# ====================================================================
    ///# ==================== DEFINES CITY ACTION SET =======================
    ///# ====================================================================
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
            
            NavigationLink {
                GymView(player: player)
            } label: { 
                Text("Gym")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }

            NavigationLink {
                DoctorsView(player: player)
            } label: {
                Text("Doctors")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            NavigationLink {
                VacationView(player: player)
            } label: {
                Text("Vacation")
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
    func deathSection() -> some View {
        VStack(spacing: 20) {
            Text("\(player.playerName ?? "") has passed away at the age \(player.playerAge).")
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundColor(Color.white)
                .shadow(radius: 5)
                .padding()
                .frame(minWidth: 350, maxWidth: 350, minHeight: 200, maxHeight: 200)
                .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                .cornerRadius(10)

            NavigationLink(destination: HomeView()) {
                Text("Start New Game")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: 300, minHeight: 80, maxHeight: 80)
                    .background(Color.green)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .padding()
        .onAppear(){
            gameScene.stopCurrentAnimation()
            gameScene.spriteDeath()
        }
    }
    
    func calculateHealthDecrease() {
        
        // Calculate additional stress based on total debt
        let debtStress = ((player.collegeDebt + player.debt) / 100000) * 125
        player.stress += debtStress
        
        // Define the stress multiplier based on the player's stress level
        let stressMultiplier: Double
        if player.stress >= 125 {
            stressMultiplier = 3.0 // Severe stress
        } else if player.stress >= 75 {
            stressMultiplier = 2.0 // High stress
        } else if player.stress >= 25 {
            stressMultiplier = 1.0 // Moderate stress
        } else {
            stressMultiplier = 0.5 // Low stress
        }

        // Calculate the health decrease using the formula
        let healthDecrease = log(Double(player.playerAge)) * stressMultiplier * 0.5

        // Update the player's health
        player.health -= healthDecrease

        // Ensure health does not drop below zero
        if player.health < 0 {
            player.health = 0
        }

        // Increase player's age by 1 year
        player.playerAge += 1

        // Print the updated health for debugging purposes
        print("Player's age: \(player.playerAge)")
        print("Health decrease: \(healthDecrease)")
        print("Player's health: \(player.health)")
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
        newPlayer.collegeMajor = ""
        newPlayer.intelligence = 1
        newPlayer.luck = 10
        newPlayer.playerAge = 21
        newPlayer.playerBalance = 350
        newPlayer.saveDate = Date()
        newPlayer.debt = 0
        newPlayer.stockBalance = 0
        newPlayer.stress = 0
        newPlayer.health = 0
        newPlayer.time = 0
        newPlayer.collegeDebt = 0
        newPlayer.collegeYear = 1
        newPlayer.hasLoan = false
        newPlayer.hasStock = false
        newPlayer.isGraduate = false
        newPlayer.isEnrolled = false
        newPlayer.isTestTime = false
        newPlayer.testTaken = false
        newPlayer.isEmployed = false
        
        return GameView(
            player: newPlayer
        )
            .environment(\.managedObjectContext, context)
    }
}
