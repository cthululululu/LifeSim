import SpriteKit
import Combine

class BlackjackScene: SKScene, ObservableObject {
    
    /// Loads the Folder "BlackJack.spriteatlas" from Assets
    /// Contains all Card sprites
    var cardAtlas: SKTextureAtlas {
        return SKTextureAtlas(named: "BlackJack")
    }
    
    @Published var deck: [SKTexture] = []
    var currentPlayerCardPosition = CGPoint(x: 50, y: 50) // Start position for the player's FIRST card
    var currentDealerCardPosition = CGPoint(x: 50, y: 280) // Start position for the dealer's FIRST card
    let cardSpacing: CGFloat = 40
    var initialCardsDealt = false
    var dealerTurn = false
    
    // Track the sum of the player's and dealer's cards
    var playerCards: [String] = [] // Store player card names
    var dealerCards: [String] = [] // Store dealer card names
    
    // Tracks the sum of PLAYER cards
    var playerSum: Int {
        var sum = 0
        var aceCount = 0
        
        // Iterates through PLAYER cards and assigns an integer value to each Card
        for card in playerCards {
            
            // Ignores the suits of the card and focuses on the rank
            let rank = card.split(separator: "_")[0]
            
            if rank == "ace" {
                aceCount += 1  // Assigns number of Aces
                sum += 1 // Assigns value for Aces
            } else if let value = Int(rank) {
                sum += value // Assigns value for cards 2-10
            } else {
                sum += 10 // Assigns Face Cards values (J,Q,K)
            }
        }
        
        // Changes Ace to 1 if Ace being 11 makes sum go over 21
        for _ in 0..<aceCount {
            if sum + 10 <= 21 {
                sum += 10
            }
        }
        return sum // Return sum of PLAYER cards
    }
    
    // Tracks the sum of DEALER cards
    var dealerSum: Int {
        var sum = 0
        var aceCount = 0
        
        // Iterates through DEALER cards and assigns an integer value to each Card
        for card in dealerCards {
            
            // Ignores the suits of the card and focuses on the rank
            let rank = card.split(separator: "_")[0]
            if rank == "ace" {
                aceCount += 1  // Assigns number of Aces
                sum += 1 // Assigns value for Aces
            } else if let value = Int(rank) {
                sum += value // Assigns value for cards 2-10
            } else {
                sum += 10 // Assigns Face Cards values (J,Q,K)
            }
        }
        
        // Changes Ace to 1 if Ace being 11 makes sum go over 21
        for _ in 0..<aceCount {
            if sum + 10 <= 21 {
                sum += 10
            }
        }
        
        return sum // Returns sum of DEALER cards
    }

    override func didMove(to view: SKView) {
        // Changes Background color to Green
        backgroundColor = SKColor(red: 74/255, green: 141/255, blue: 70/255, alpha: 1)
        // Loads card textures
        loadCardTextures()
    }
    
    // Uses the final results of the game to allocate money
    func printGameResult(betAmount: Int, player: PlayerData) {
        if playerSum > 21 {
            //print("Player busts. Dealer wins!")
            player.playerBalance -= Double(betAmount)
        } else if dealerSum > 21 {
            //print("Dealer busts. Player wins!")
            player.playerBalance += Double(betAmount)
        } else if playerSum > dealerSum {
            //print("Player wins with \(playerSum) against dealer's \(dealerSum)!")
            player.playerBalance += Double(betAmount)
        } else if dealerSum > playerSum {
            //print("Dealer wins with \(dealerSum) against player's \(playerSum)!")
            player.playerBalance -= Double(betAmount)
        } else {
            //print("It's a standoff with both at \(playerSum)!")
        }
    }
    
    // Controls the play of the Dealer
    func dealerPlay(betAmount: Int, player: PlayerData) {
        if dealerSum < 17 {
            dealDealerCard(faceUp: true)
            //print("Dealer's card sum: \(dealerSum)")
            
            // Dealer hit's card in 0.5 second intervals
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dealerPlay(betAmount: betAmount, player: player)
            }
        } else {
            //print("Dealer stands with a total of: \(dealerSum)")
            
            // Ends dealer's turn
            dealerTurn = false
            // Allocates money using final results of game
            printGameResult(betAmount: betAmount, player: player)
        }
    }

    // Function clears all cards off the Scene after game has ended
    func clearCards() {
        // Remove all card nodes
        for child in children {
            if child.name?.starts(with: "faceup_card") == true || child.name == "facedown_card" {
                child.removeFromParent()
            }
        }
        // Resets positions and states
        currentPlayerCardPosition = CGPoint(x: 50, y: 50)
        currentDealerCardPosition = CGPoint(x: 50, y: 280)
        playerCards.removeAll()
        dealerCards.removeAll()
        initialCardsDealt = false
        dealerTurn = false
    }

    // Load all card textures into the deck using Sprite Atlas
    func loadCardTextures() {
        
        let suits = ["hearts", "diamonds", "clubs", "spades"]
        let ranksPart1 = ["ace", "2", "3", "4", "5", "6", "7"]
        let ranksPart2 = ["8", "9", "10", "jack", "queen", "king"]
        let ranks = ranksPart1 + ranksPart2
        
        for suit in suits {
            for rank in ranks {
                let cardTexture = cardAtlas.textureNamed("\(rank)_\(suit)")
                deck.append(cardTexture)
            }
        }
        // TEST: Verifies all Blackjack assets have loaded
        //print("Deck contains: \(deck.map { $0.description })")
    }
    
    // Hit functionality: Ensures ability to add another card to Player deck
    func hit(betAmount: Int, player: PlayerData, shouldUpdate: UnsafeMutablePointer<Bool>) {
        
        if !initialCardsDealt {
            
            // Deal the initial two cards to PLAYER
            dealPlayerCard()
            dealPlayerCard()
            
            // Deal the initial two cards to the dealer
            dealDealerCard(faceUp: true)
            dealDealerCard(faceUp: false) // Facedown Card
            
            // Validates all initial cards dealt
            initialCardsDealt = true
            
        } else {
            // All hits after initial hit generate only one card at a time
            dealPlayerCard()
        }
        
        // Check if the player sum is 21 or more
        if playerSum == 21 {
            print("Player hits 21!")
            shouldUpdate.pointee = true
            stand(betAmount: betAmount, player: player)
        } else if playerSum > 21 {
            // Forces stand if PLAYER card sum Busts (Over 21)
            print("Player busts!")
            shouldUpdate.pointee = true
            stand(betAmount: betAmount, player: player)
        } else {
            shouldUpdate.pointee = false
        }
    }

    
    func dealPlayerCard() {
        guard let cardTexture = deck.randomElement() else {
            print("No card texture found")
            return
        }
        
        let cardName = cardTexture.description.split(separator: "'")[1]
        playerCards.append(String(cardName))
        
        let card = SKSpriteNode(texture: cardTexture)
        card.name = "faceup_card_player_" + String(playerCards.count)
        card.position = currentPlayerCardPosition // Set position for next card
        card.setScale(1.2) // Sets player card Size
        addChild(card)
        
        // TEST: Ensures player card added
        //print("Player card added to BlackjackScene")

        // Updates position for the next card
        currentPlayerCardPosition.x += (card.size.width * 0.8 / 2) + cardSpacing
    }


    
    func dealDealerCard(faceUp: Bool, at position: CGPoint? = nil) {
        let cardTexture: SKTexture

        if faceUp {
            guard let texture = deck.randomElement() else {
                print("No card texture found")
                return
            }
            cardTexture = texture
        } else {
            cardTexture = cardAtlas.textureNamed("facedown_card") // Use the facedown card texture
        }

        let card = SKSpriteNode(texture: cardTexture)
        card.name = faceUp ? "faceup_card" : "facedown_card"
        card.position = position ?? currentDealerCardPosition
        card.setScale(1.3)
        addChild(card)
        if faceUp && position == nil {
            currentDealerCardPosition.x += (card.size.width / 2) + cardSpacing
        }
        
        if faceUp {
            let cardName = cardTexture.description.split(separator: "'")[1]
            dealerCards.append(String(cardName))
        }
    }
    
    func stand(betAmount: Int, player: PlayerData) {
        
        dealerTurn = true
        revealDealerFacedownCard(betAmount: betAmount, player: player)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.clearCards()
        }
    }

    
    func revealDealerFacedownCard(betAmount: Int, player: PlayerData) {
        guard let facedownCard = children.first(where: { $0.name == "facedown_card" }) as? SKSpriteNode else {
            print("No facedown card found")
            return
        }
        
        let facedownCardPosition = facedownCard.position
        facedownCard.removeFromParent()
        dealDealerCard(faceUp: true, at: facedownCardPosition)
        currentDealerCardPosition = CGPoint(x: facedownCardPosition.x + (facedownCard.size.width / 2) + cardSpacing, y: facedownCardPosition.y)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dealerPlay(betAmount: betAmount, player: player)
        }
    }
}
