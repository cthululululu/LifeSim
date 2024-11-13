/**
    #GameView.swift
 
    The main game UI where gameplay will take place.
    Currently serves no functionality besides displaying
    player's game save information.
 */

import SwiftUI
import CoreData
import SpriteKit



struct GameView: View, Hashable {
    
    // Observes changes to PlayerData instance
    @ObservedObject var player: PlayerData
    @State var selectedCharacterIndex = 0
   
   //Character names
    let characters = ["John", "Jane"]

    private var formattedSaveData: String {
        
        // If saved data exists
        if let playerName = player.playerName, let saveDate = player.saveDate {
            
            // Formats date and stores formatted date into formattedDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(from: saveDate)
            
            // Displays saved data
            return "Saved Game Data: \(playerName)\nOn: \(formattedDate)"
        } else {
            
            // No saved data to display
            return "No saved game data available"
        }
    }

  
    var body: some View {
        NavigationStack {
            VStack (alignment: .center){
                HStack() {
                    //character animations
                    GameViewControllerRepresentable(selectedCharacterIndex: $selectedCharacterIndex)
                        .frame(width: 200, height: 580)

                    Text("Character: \(characters[selectedCharacterIndex])")
                        .font(.title)
                        .padding(.top, 20)
                }
                
                Text(formattedSaveData)
                    .font(.title)  // Text displays formattedSaveData
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem (placement: .principal) {
                    Text("Life Sim")
                        .font(.largeTitle)
                        .padding(.top, 20)
                }
            }
            
        }
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

//contains sprite animations and logic for choosing character
class GameScene: SKScene {
    var characterIndex: Int = 0 //0 for boy, 1 for girl
    var playerBoy: SKSpriteNode!
    var playerGirl: SKSpriteNode!
    
    var onCharacterChanged: ((Int) -> Void)?
    
    //Texture atlas for all characters
    var playerAtlas: SKTextureAtlas {
        return SKTextureAtlas(named: "Sprites")
    }
    
    //Texture for boy idle animation
    var playerIdleTexturesBoy: [SKTexture] {
        return (1...15).map {playerAtlas.textureNamed("Idle (\($0))")}
    }
    
    //Texture for girl idle animation
    var playerIdleTexturesGirl: [SKTexture] {
       return (2...16).map {playerAtlas.textureNamed("Girl (\($0))")}
        
    }
    //Initial player texture and position
     func setUpPlayers() {
        //Setting up Boy Character Sprite
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playerBoy = SKSpriteNode(texture: playerIdleTexturesBoy[0])
        playerBoy.setScale(0.3)
        playerBoy.position = CGPoint(x:-10, y:0) //Center of the scene
        //Setting up Girl Character Sprite
        playerGirl = SKSpriteNode(texture: playerIdleTexturesGirl[0])
        playerGirl.setScale(0.3)
        playerGirl.position = CGPoint(x: 50, y: 0)
        
         //add to scene
         addChild(playerBoy)
         addChild(playerGirl)
    }
    //Called when scene appears
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        setUpPlayers()
        startIdleAnimations() //idle animation starts
    }
   
    func switchCharacter(to index: Int) {
        onCharacterChanged?(index)
    }
    //animating sprites
    func startIdleAnimations() {
        let boyidleAnimation = SKAction.animate(with: playerIdleTexturesBoy, timePerFrame: 0.05)
        playerBoy.run(SKAction.repeatForever(boyidleAnimation), withKey: "playerIdleAnimationBoy")
        let girlidleAnimation = SKAction.animate(with: playerIdleTexturesGirl, timePerFrame: 0.05)
        playerGirl.run(SKAction.repeatForever(girlidleAnimation), withKey: "playerIdleAnimationGirl")
    }
    //touch logic for switching character
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        if playerBoy.contains(location) {
            switchCharacter(to: 0)
        }
        if playerGirl.contains(location) {
            switchCharacter(to: 1)
        }
    }
    
   
    
}


// For XCode Preview Purposes only:
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newPlayer = PlayerData(context: context)
        newPlayer.playerName = "Example Player"
        newPlayer.saveDate = Date()

        return GameView(player: newPlayer)
            .environment(\.managedObjectContext, context)
    }
}
