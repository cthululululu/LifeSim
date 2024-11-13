import UIKit

class ContentView: UIViewController {

    @IBOutlet weak var loadGameButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    
    var gameData: String? // This will hold your game data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ContentView loaded") // Debugging output
        // Load saved game data if available
        if let savedGame = UserDefaults.standard.string(forKey: "savedGame") {
            gameData = savedGame
        }
    }
    
    @IBAction func loadGameTapped(_ sender: UIButton) {
        if let gameData = gameData {
            // Load the game
            print("Game Loaded: \(gameData)")
        } else {
            // No saved game
            let alert = UIAlertController(title: "No Saved Game", message: "There is no saved game to load.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func newGameTapped(_ sender: UIButton) {
        if gameData != nil {
            // Alert user that starting a new game will overwrite the saved game
            let alert = UIAlertController(title: "Overwrite Save", message: "Starting a new game will overwrite your previous save. Continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Continue", style: .destructive, handler: { _ in
                self.startNewGame()
            }))
            present(alert, animated: true, completion: nil)
        } else {
            startNewGame()
        }
    }
    
    func startNewGame() {
        // Start a new game
        gameData = "New Game Data"
        UserDefaults.standard.set(gameData, forKey: "savedGame")
        print("New Game Started")
    }
}
