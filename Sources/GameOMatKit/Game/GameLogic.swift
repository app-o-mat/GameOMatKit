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
    func currentPlayerMisses()
}

public protocol GameLogicDelegate: class {
    var gameState: GameState { get }

    func didGameOver()
    func scene() -> SKScene
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
}
