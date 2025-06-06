import SpriteKit


// contains sprite animations and logic for choosing character
class GameScene: SKScene, ObservableObject {
    var gender: String
    var playerName: String
    var nameLabel: SKLabelNode!
    var playerBoy: SKSpriteNode!
    var playerGirl: SKSpriteNode!
    
    init(size: CGSize, playerName: String, gender: String) {
        self.playerName = playerName
        self.gender = gender
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    //Texture for boy sprite death
    var playerDeathTextureGirl: [SKTexture] {
        return (1...30).map { playerAtlas.textureNamed("girlDead (\($0))")}
    }
    //Texture for girl sprite death
    var playerDeathTextureBoy: [SKTexture] {
        return (1...15).map { playerAtlas.textureNamed("Dead (\($0))")}
    }
    
    //Texture for happy girl sprite
    var playerHappyGirl: [SKTexture] {
        return (2...15).map { playerAtlas.textureNamed("girlHappy (\($0))")}
    }
    //Texture for sad girl sprite
    var playerSadGirl: [SKTexture] {
        return (2...15).map { playerAtlas.textureNamed("girlSad (\($0))")}
    }
    //Texture for happy boy sprite
    var playerHappyBoy: [SKTexture] {
        return (1...15).map { playerAtlas.textureNamed("boyHappy (\($0))")}
    }
    //Texture for sad boy sprite
    var playerSadBoy: [SKTexture] {
        return (1...15).map { playerAtlas.textureNamed("boySad (\($0))")}
    }
    
    // Function for calling happy sprite animation
    func happyAnimation() {
        ensurePlayersAreSetUp()
        
        // Ensure textures are loaded and not empty
        guard !playerHappyBoy.isEmpty || !playerHappyGirl.isEmpty else {
            print("Error with texture: Happy textures are empty")
            return
        }
        
        let happyTextures: SKAction
        
        if gender == "Male" {
            happyTextures = SKAction.animate(with: playerHappyBoy, timePerFrame: 0.05)
            playerBoy.run(happyTextures, withKey: "happyAnimation")
        } else {
            happyTextures = SKAction.animate(with: playerHappyGirl, timePerFrame: 0.05)
            playerGirl.run(happyTextures, withKey: "happyAnimation")
        }
    }

    
    //Function for calling sad sprite animation
    func sadAnimation() {
        let sadTextures: SKAction
        if gender == "Male" {
            sadTextures = SKAction.animate(with: playerSadBoy, timePerFrame: 0.05)
            playerBoy.run(sadTextures, withKey: "sadAnimation")
        }
        else {
            sadTextures = SKAction.animate(with: playerSadGirl, timePerFrame: 0.05)
            playerGirl.run(sadTextures, withKey: "sadAnimation")
        }
    }

    // Function to ensure sprite nodes are set up
    func ensurePlayersAreSetUp() {
        if playerBoy == nil || playerGirl == nil {
            setUpPlayers()
        } else {
            if playerBoy.parent == nil {
                addChild(playerBoy)
            }
            if playerGirl.parent == nil {
                addChild(playerGirl)
            }
        }
    }


    // Function for calling death animation
    func spriteDeath() {
        ensurePlayersAreSetUp()

        let deathTextures: [SKTexture]
        let sprite: SKSpriteNode

        if gender == "Male" {
            deathTextures = playerDeathTextureBoy
            sprite = playerBoy
        } else {
            deathTextures = playerDeathTextureGirl
            sprite = playerGirl
        }

        guard !deathTextures.isEmpty else {
            print("Error with texture: Empty deathTextures")
            return
        }

        // Stop all actions and hide the sprite to avoid overlap
        sprite.removeAllActions()
        sprite.isHidden = true

        // Create a temporary node for the death animation
        let tempSprite = SKSpriteNode(texture: deathTextures.first)
        tempSprite.position = sprite.position
        tempSprite.setScale(0.6)
        addChild(tempSprite)

        let deathAnimation = SKAction.animate(with: deathTextures, timePerFrame: 0.05)

        let setLastFrame = SKAction.run {
            tempSprite.texture = deathTextures.last
            sprite.isHidden = true // Keep the original sprite hidden
        }

        let sequence = SKAction.sequence([deathAnimation, setLastFrame])

        print("Running death animation")

        tempSprite.run(sequence, withKey: "playerDeathAnimation")
    }

    
    //func to stop current animation, this is to avoid overlaps
    func stopCurrentAnimation() {
        // Ensure playerBoy is initialized and safely remove all actions
        if let playerBoy = playerBoy {
            playerBoy.removeAllActions()
        } else {
            print("playerBoy is nil in stopCurrentAnimation")
        }
        
        // Ensure playerGirl is initialized and safely remove all actions
        if let playerGirl = playerGirl {
            playerGirl.removeAllActions()
        } else {
            print("playerGirl is nil in stopCurrentAnimation")
        }
    }

    
    
    func configureCharacter(name: String, gender:String) {
        self.gender = gender
        self.playerName = name
        setUpPlayers()
    }
    
    // Initial player texture and position
    func setUpPlayers() {
        if playerBoy == nil {
            // Setting up Boy Character Sprite
            playerBoy = SKSpriteNode(imageNamed: "maleSprite")
            playerBoy.position = CGPoint(x: size.width/2 + 32, y: size.height/2)
            playerBoy.setScale(0.7)
            addChild(playerBoy)
        }

        if playerGirl == nil {
            // Setting up Girl Character Sprite
            playerGirl = SKSpriteNode(imageNamed: "femaleSprite")
            playerGirl.position = CGPoint(x: size.width/2 - 5, y: size.height/2)
            playerGirl.setScale(0.7)
            addChild(playerGirl)
        }
        
        nameLabel = SKLabelNode(text: playerName)
        nameLabel.fontSize = 35
        nameLabel.fontColor = .black
        nameLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 75)
        addChild(nameLabel)
        
        if gender == "Male" {
            playerBoy.isHidden = false
            playerGirl.isHidden = true
        } else {
            playerBoy.isHidden = true
            playerGirl.isHidden = false
        }
        startIdleAnimations()
    }

    
    // Called when scene appears
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        setUpPlayers()
    }
    
    
    // Animating sprites
    func startIdleAnimations() {
        let boyIdleAnimation = SKAction.animate(with: playerIdleTexturesBoy, timePerFrame: 0.05)
        playerBoy.run(SKAction.repeatForever(boyIdleAnimation), withKey: "playerIdleAnimationBoy")
        
        let girlIdleAnimation = SKAction.animate(with: playerIdleTexturesGirl, timePerFrame: 0.05)
        playerGirl.run(SKAction.repeatForever(girlIdleAnimation), withKey: "playerIdleAnimationGirl")
    }
    
}
