//
//  GameViewController.swift
//  LifeSim
//
//  Created by Sadie Argueta on 11/12/24.
//

import Foundation
import SpriteKit
import SwiftUI

class GameViewController: UIViewController {
    private lazy var gameView = SKView()
    var characterIndex: Int = 0 //character index passed to the scene
    var onCharacterChanged: ((Int) -> Void)?
    
    override func loadView() {
        view = gameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: gameView.bounds.size)
        scene.scaleMode = .resizeFill
        
        scene.onCharacterChanged = { [weak self] newIndex in
            self?.characterIndex = newIndex
            self?.onCharacterChanged?(newIndex)
        }
        gameView.presentScene(scene)
    }
    
    func updateCharacter() {
        if let scene = gameView.scene as? GameScene {
            scene.switchCharacter(to: characterIndex) //update character in scene
        }
    }
}

struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var selectedCharacterIndex: Int
    
    func makeUIViewController(context: Context) -> GameViewController {
        let viewController = GameViewController()
        viewController.onCharacterChanged = { newIndex in
            selectedCharacterIndex = newIndex
        }
        return viewController
    }
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        if uiViewController.characterIndex != selectedCharacterIndex {
            uiViewController.characterIndex = selectedCharacterIndex
            
        }
    }
}
