//
//  PongOnePlayerLogic.swift
//  MathOMat
//
//  Created by Louis Franco on 12/20/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public class PongOnePlayerLogic: PongGameLogic, GameLogicPlayers {

    var player: PongPlayer
    public let players: [Player]
    var guideLine: SKNode?
    var guideOffset: CGFloat = 0

    public override init(generator: ProblemGenerator) {
        self.player = PongPlayer(problemRotation: 0, position: .bottom)
        self.players = [player]
        super.init(generator: generator)
    }

    public override func reset() {
        super.reset()
        self.player.score = 0
        self.guideLine?.run(SKAction.moveTo(y: 0, duration: 0.25))
    }

    public override func getPlayers() -> GameLogicPlayers? {
        return self
    }

    public override func addBoardNodes() {
        super.addBoardNodes()
        guard let scene = self.scene else { return }

        createPlayerNodes(yPosition: lineOffset(), playerIndex: 0)

        let guidePos = scene.size.height / 2.0
        self.guideLine = createShowButtonsLine(scene: scene, yPosition: guidePos, playerIndex: 0)
    }

    override func addScoreNode(playerIndex: Int, yPosition: CGFloat) {
        super.addScoreNode(playerIndex: playerIndex, yPosition: yPosition)
        guard let scene = self.scene, let view = scene.view else { return }

        let score = self.player.scoreNode
        score.text = "\(self.player.score)"
        score.fontName = Style.fontName
        score.fontSize = Style.scoreFontSize
        score.position = CGPoint(x: scene.size.width / 2,
                                 y: scene.size.height - view.safeAreaInsets.top - score.frame.size.height - 10)
        add(node: score, to: scene)
    }

    override func initialPosition(scene: SKScene) -> CGPoint {
        guard let view = scene.view else { return super.initialPosition(scene: scene) }

        return CGPoint(x: scene.size.width / 2, y: scene.size.height - view.safeAreaInsets.top)
    }

    override func initialVelocity(scene: SKScene) -> CGVector {
        let dxy: CGFloat = scene.size.height * 0.1
        return CGVector(dx: dxy * 0.5, dy: -dxy)
    }

    override func createButtons() {
        super.createButtons()
        self.scene?.hidePauseButton()
    }

    private func startNextProblem(scene: SKScene) {
        self.problemNode?.physicsBody = nil
        self.problemNode?.position = initialPosition(scene: scene)
        self.currentProblem = self.generator.getNextProblem()
        self.scene?.showPauseButton()
    }

    public func currentPlayerHits() {
        guard let scene = self.scene else { return }
        guard let velocity = self.problemNode?.physicsBody?.velocity else { return }

        scene.run(self.winSoundAction)

        startNextProblem(scene: scene)
        self.problemNode?.physicsBody?.velocity =
            CGVector(dx: velocity.dx, dy: velocity.dy * 1.05)

        self.player.score += 1
    }

    public func currentPlayerTapsWrongButton() {
        guard let scene = self.scene else { return }
        guard let velocity = self.problemNode?.physicsBody?.velocity else { return }

        scene.run(self.loseSoundAction)

        startNextProblem(scene: scene)
        self.problemNode?.physicsBody?.velocity =
            CGVector(dx: velocity.dx * 1.15, dy: velocity.dy * 1.25)

        guideOffset = max(guideOffset - 15, -75)
        self.guideLine?.run(SKAction.moveTo(y: guideOffset, duration: 0.25))

        self.player.score = max(0, self.player.score - 1)
    }

    public func currentPlayerMisses() {
        guard let scene = self.scene else { return }

        scene.run(self.loseSoundAction)
        gameOver()
    }
}
