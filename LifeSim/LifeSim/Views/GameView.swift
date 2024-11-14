import SwiftUI
import CoreData
import SpriteKit

// Enumeration that defines each section of buttons
enum GameSection {
    case main, finances, job, relationships, education, assets, city, casino, blackjack
}

struct GameView: View, Hashable {
    
    // Observes changes to PlayerData instance
    @ObservedObject var player: PlayerData
    // Initializes current game section to being in the main section
    @State private var currentSection: GameSection = .main
    @State var selectedCharacterIndex = 0
    // Character names
    let characters = ["John", "Jane"]
    
    
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
                HStack {
                    // Character animations
                    GameViewControllerRepresentable(selectedCharacterIndex: $selectedCharacterIndex)
                        .frame(width: 200, height: 580)
                    
                    Text("Character: \(characters[selectedCharacterIndex])")
                        .font(.title)
                        .padding(.top, 20)
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
            Button(action: { print("Go to Bank") }) {
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
    
    // Blackjack Button Set
    func blackjackButtons() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 20) {
            Button(action: { currentSection = .casino }) {
                Text("Back")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Hit") }) {
                Text("Hit")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                    .background(Color.cyan)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            Button(action: { print("Stand") }) {
                Text("Stand")
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


///# ============= SPRITEKIT TOOLS =============

// contains sprite animations and logic for choosing character
class GameScene: SKScene {
    var characterIndex: Int = 0 // 0 for boy, 1 for girl
    var playerBoy: SKSpriteNode!
    var playerGirl: SKSpriteNode!
    
    var onCharacterChanged: ((Int) -> Void)?
    
    // Texture atlas for all characters
    var playerAtlas: SKTextureAtlas {
        return SKTextureAtlas(named: "Sprites")
    }
    
    // Texture for boy idle animation
    var playerIdleTexturesBoy: [SKTexture] {
        return (1...15).map { playerAtlas.textureNamed("Idle (\($0))") }
    }
    
    // Texture for girl idle animation
    var playerIdleTexturesGirl: [SKTexture] {
        return (2...16).map { playerAtlas.textureNamed("Girl (\($0))") }
    }
    
    // Initial player texture and position
    func setUpPlayers() {
        // Setting up Boy Character Sprite
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playerBoy = SKSpriteNode(texture: playerIdleTexturesBoy[0])
        playerBoy.setScale(0.3)
        playerBoy.position = CGPoint(x:-10, y:0) // Center of the scene
        
        // Setting up Girl Character Sprite
        playerGirl = SKSpriteNode(texture: playerIdleTexturesGirl[0])
        playerGirl.setScale(0.3)
        playerGirl.position = CGPoint(x: 50, y: 0)
        
        // Add to scene
        addChild(playerBoy)
        addChild(playerGirl)
    }
    
    // Called when scene appears
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        setUpPlayers()
        startIdleAnimations() // Idle animation starts
    }
    
    func switchCharacter(to index: Int) {
        onCharacterChanged?(index)
    }
    
    // Animating sprites
    func startIdleAnimations() {
        let boyIdleAnimation = SKAction.animate(with: playerIdleTexturesBoy, timePerFrame: 0.05)
        playerBoy.run(SKAction.repeatForever(boyIdleAnimation), withKey: "playerIdleAnimationBoy")
        
        let girlIdleAnimation = SKAction.animate(with: playerIdleTexturesGirl, timePerFrame: 0.05)
        playerGirl.run(SKAction.repeatForever(girlIdleAnimation), withKey: "playerIdleAnimationGirl")
    }
    
    // Touch logic for switching character
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        if playerBoy.contains(location) {
            switchCharacter(to: 0)
        } else if playerGirl.contains(location) {
            switchCharacter(to: 1)
        }
        
        
    }
} ///# ============= END OF SPRITEKIT TOOLS =============

// Assuming GameView is the main view you want to preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Creating a sample PlayerData instance for preview purposes
        let newPlayer = PlayerData(context: context)
        newPlayer.playerName = "Sample Player"
        newPlayer.saveDate = Date()
        
        return GameView(player: newPlayer)
            .environment(\.managedObjectContext, context)
    }
}
