//
//  PongTwoPlayerLogic.swift
//  MathOMat
//
//  Created by Louis Franco on 12/19/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public class PongTwoPlayerLogic: PongGameLogic, GameLogicPlayers {

    var gameOptions = GameOptions(name: "pong-2p-goal", options: [
        GameOption(buttonImagePrefix: "pong-2p-7"),
        GameOption(buttonImagePrefix: "pong-2p-14"),
        GameOption(buttonImagePrefix: "pong-2p-21"),
    ])

    public let players: [Player] = [
        PongPlayer(problemRotation: 0, position: .bottom),
        PongPlayer(problemRotation: .pi, position: .top)]

    public override func reset() {
        super.reset()

        self.getPongPlayers().forEach { $0.score = 0}
    }

    public override func getPlayers() -> GameLogicPlayers? {
        return self
    }

    public override func addBoardNodes() {
        super.addBoardNodes()
        guard let scene = self.scene else { return }

        createPlayerNodes(yPosition: lineOffset(), playerIndex: 0)
        createPlayerNodes(yPosition: scene.size.height - lineOffset(), playerIndex: 1)

        let guidePos = scene.size.height / 3.0
        createShowButtonsLine(scene: scene, yPosition: guidePos, playerIndex: 0)
        createShowButtonsLine(scene: scene, yPosition: scene.size.height - guidePos, playerIndex: 1)
    }

    public override func setUpProblem(problemNode: SKSpriteNode, label: SKLabelNode) {
        let problemSize = label.frame.size

        let rotation = self.getPongPlayers()[self.currentPlayer].problemRotation
        label.zRotation = rotation
        if rotation == 0.0 {
            label.position = CGPoint(x: 0, y: -problemSize.height / 2.0)
        } else {
            label.position = CGPoint(x: 0, y: problemSize.height / 2.0)
        }
    }

    open override func options() -> GameOptions {
        return gameOptions
    }

    override func addScoreNode(playerIndex: Int, yPosition: CGFloat) {
        super.addScoreNode(playerIndex: playerIndex, yPosition: yPosition)
        guard let scene = self.scene else { return }

        let score = self.getPongPlayers()[playerIndex].scoreNode
        score.text = "\(self.getPongPlayers()[playerIndex].score)"
        score.fontName = Style.fontName
        score.fontSize = Style.scoreFontSize
        score.position = CGPoint(x: score.fontSize + 5, y: yPosition - 50 * CGFloat(playerIndex * 2 - 1))
        score.zRotation = .pi / 2.0
        add(node: score, to: scene)
    }

    public func currentPlayerHits() {
        guard let scene = self.scene else { return }

        guard let velocity = self.problemNode?.physicsBody?.velocity else { return }
        scene.run(self.winSoundAction)

        self.currentPlayer = 1 - self.currentPlayer
        self.problemNode?.physicsBody?.velocity = CGVector(dx: velocity.dx * 1.1, dy: -velocity.dy * 1.1)

        self.currentProblem = self.generator.getNextProblem()
    }

    public func currentPlayerTapsWrongButton() {
        currentPlayerMisses()
    }

    func goalScore() -> Int {
        return ((self.gameOptions.chosenIndex() ?? 0) + 1 ) * 7
    }

    public func currentPlayerMisses() {
        guard let scene = self.scene else { return }

        scene.run(self.loseSoundAction)

        let otherPlayer = 1 - currentPlayer
        self.getPongPlayers()[otherPlayer].score += 1

        guard self.getPongPlayers()[otherPlayer].score < goalScore() else { return gameOver() }

        self.problemNode?.physicsBody = nil
        self.problemNode?.position = initialPosition(scene: scene)

        self.currentProblem = self.generator.getNextProblem()
    }

    override func initialVelocity(scene: SKScene) -> CGVector {
        let dxy: CGFloat = scene.size.height * 0.1
        return CGVector(dx: dxy * 0.5, dy: dxy * CGFloat(self.currentPlayer * 2 - 1))
    }
}
