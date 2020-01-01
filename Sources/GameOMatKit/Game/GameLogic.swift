//
//  GameLogic.swift
//  
//
//  Created by Louis Franco on 12/22/19.
//

import Foundation
import SpriteKit

public protocol Player {
}

public protocol GameLogicPlayers {
    var players: [Player] { get }

    func currentPlayerHits()
    func currentPlayerTapsWrongButton()
    func currentPlayerMisses()
}

public protocol GameLogicDelegate: class {
    var gameState: GameState { get }

    func didGameOver()
    func scene() -> GameScene
}

public class GameOption {
    let buttonImagePrefix: String
    var on: Bool = false

    init(buttonImagePrefix: String) {
        self.buttonImagePrefix = buttonImagePrefix
    }
}

public class GameOptions {
    let name: String
    var options: [GameOption]

    private lazy var key = { "\(SettingKey.prefix).\(self.name)" }()

    init(name: String, options: [GameOption]) {
        self.name = name
        self.options = options
        if let saved = UserDefaults.standard.string(forKey: self.key) {
            if let chosenOption = options.first(where: { $0.buttonImagePrefix == saved }) {
                chosenOption.on = true
            } else {
                options.first?.on = true
            }
        } else {
            options.first?.on = true
        }
    }

    func tap(option: GameOption) {
        options.forEach { $0.on = ($0 === option) }
        UserDefaults.standard.set(option.buttonImagePrefix, forKey: self.key)
    }

    func chosen() -> GameOption? {
        return options.first(where: { $0.on })
    }

    func chosenIndex() -> Int? {
        return options.firstIndex(where: { $0.on })
    }
}

public protocol GameLogic: SKPhysicsContactDelegate {
    var delegate: GameLogicDelegate? { get set }
    var generator: ProblemGenerator { get set }

    func reset()
    func addBoardNodes()
    func run()
    func gameOver()
    func removeAllNodes()
    func getPlayers() -> GameLogicPlayers?
    func options() -> GameOptions
}
