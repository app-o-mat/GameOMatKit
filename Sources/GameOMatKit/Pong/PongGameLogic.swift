//
//  PongGameLogic.swift
//  MathOMat
//
//  Created by Louis Franco on 12/20/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit

public class PongGameLogic: NSObject, GameLogic {
    var allNodes = [SKNode]()

    public let style: PongStyle

    public weak var delegate: GameLogicDelegate?

    public var generator: ProblemGenerator {
        didSet {
            self.currentProblem = generator.getNextProblem()
        }
    }

    var problemNode: SKNode?
    var currentProblem: Problem {
        didSet {
            didSetCurrentProblem()
        }
    }

    var currentPlayer = 0
    var answerButtonWidth: CGFloat {
        guard let font = UIFont(name: Style.fontName, size: self.style.buttonFontSize) else { return 0 }

        return NSString(" ").size(withAttributes: [NSAttributedString.Key.font: font]).width *
            CGFloat(generator.maxAnswerLength) + 10.0
    }

    let winSoundAction = SKAction.playSoundFileNamed("win", waitForCompletion: false)
    let loseSoundAction = SKAction.playSoundFileNamed("lose", waitForCompletion: false)

    var scene: GameScene? {
        return self.delegate?.scene()
    }

    public init(generator: ProblemGenerator, style: PongStyle = PongStyle()) {
        self.generator = generator
        self.style = style
        self.currentProblem = generator.getNextProblem()
        super.init()
    }

    public func getPlayers() -> GameLogicPlayers? {
        return nil
    }

    public func getPongPlayers() -> [PongPlayer] {
        guard let players = getPlayers() else { return [] }
        return players.players.compactMap { $0 as? PongPlayer }
    }

    public func reset() {
    }

    public func removeAllNodes() {
        allNodes.forEach { node in
            guard node.parent != nil else { return }
            node.removeFromParent()
        }
    }

    public func addBoardNodes() {
        guard let scene = self.scene else { return }
        createGameBoundary(xPosition: Style.sideInset)
        createGameBoundary(xPosition: scene.size.width - Style.sideInset)
    }

    public func run() {
        createProblem()
    }

    open func options() -> GameOptions {
        return GameOptions(name: "", options: [])
    }

    func add(node: SKNode, to parent: SKNode) {
        parent.addChild(node)
        allNodes.append(node)
    }

    func createGameBoundary(xPosition: CGFloat) {
        guard let scene = self.scene else { return }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: scene.size.height))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = Style.boundaryLineWidth
        boundary.strokeColor = AppColor.boundaryColor

        boundary.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        boundary.setupAsBoundary()
        boundary.setupAsObject()

        add(node: boundary, to: scene.gameNodeRoot)
    }

    func createProblem() {
        guard let scene = self.scene else { return }
        let label = SKLabelNode(text: self.currentProblem.question)
        label.fontSize = self.style.problemFontSize
        label.fontName = Style.fontName

        let problemSize = label.frame.size
        let problemNode = SKSpriteNode(color: AppColor.problemBackground, size: problemSize)
        self.problemNode = problemNode
        add(node: problemNode, to: scene.gameNodeRoot)

        problemNode.name = NodeName.problemName
        problemNode.position = initialPosition(scene: scene)
        add(node: label, to: problemNode)

        didSetCurrentProblem()
    }

    public func gameOver() {
        self.problemNode?.removeFromParent()
        self.problemNode = nil

        removeButtons()

        delegate?.didGameOver()
    }

    func setUpProblem(problemNode: SKSpriteNode, label: SKLabelNode) {

    }

    func didSetCurrentProblem() {
        guard
            let problemNode = self.problemNode as? SKSpriteNode,
            let label = problemNode.children[0] as? SKLabelNode,
            let scene = delegate?.scene()
        else { return }

        label.text = currentProblem.question
        let problemSize = label.frame.size

        setUpProblem(problemNode: problemNode, label: label)

        problemNode.size = problemSize
        let newPhysicsBody = problemPhysicsBody(scene: scene, size: problemSize)
        if let physicsBody = problemNode.physicsBody {
            newPhysicsBody.velocity = physicsBody.velocity
        }
        problemNode.physicsBody = newPhysicsBody
        removeButtons()
    }

    func problemPhysicsBody(scene: SKScene, size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.linearDamping = 0.0
        physicsBody.contactTestBitMask = SKNode.categoryGuide | SKNode.categoryObject
        physicsBody.allowsRotation = false

        physicsBody.setupAsObject()
        physicsBody.velocity = initialVelocity(scene: scene)

        return physicsBody
    }

    func initialPosition(scene: SKScene) -> CGPoint {
        return CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
    }

    func initialVelocity(scene: SKScene) -> CGVector {
        return CGVector(dx: 0, dy: 0)
    }

    func addScoreNode(playerIndex: Int, yPosition: CGFloat) {
    }

    func createPlayerNodes(yPosition: CGFloat, playerIndex: Int) {
        guard let scene = self.scene else { return }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: Style.sideInset, y: yPosition))
        path.addLine(to: CGPoint(x: scene.size.width - Style.sideInset, y: yPosition))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = Style.boundaryLineWidth
        boundary.strokeColor = AppColor.boundaryColor
        boundary.name = NodeName.playerLineName[playerIndex]

        boundary.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        boundary.setupAsBoundary()
        boundary.setupAsGuide()

        add(node: boundary, to: scene.gameNodeRoot)

        addScoreNode(playerIndex: playerIndex, yPosition: yPosition)
    }

    @discardableResult
    func createShowButtonsLine(scene: GameScene, yPosition: CGFloat, playerIndex: Int) -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: Style.sideInset, y: yPosition))
        path.addLine(to: CGPoint(x: scene.size.width - Style.sideInset, y: yPosition))

        let guide = SKShapeNode(path: path)
        guide.lineWidth = Style.guideLineWidth
        guide.strokeColor = AppColor.guideColor
        guide.name = NodeName.buttonLineName[playerIndex]

        guide.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        guide.setupAsBoundary()
        guide.setupAsGuide()

        add(node: guide, to: scene.gameNodeRoot)
        return guide
    }

    func removeButtons() {
        getPongPlayers().forEach { $0.removeButtons() }
    }

    func createButtons() {
        guard let scene = self.scene else { return }

        removeButtons()
        let buttons = getPongPlayers()[currentPlayer]
            .addButtons(scene: scene, rootNode: scene.gameNodeRoot, problem: currentProblem, lineOffset: lineOffset(),
                        buttonWidth: self.answerButtonWidth, style: self.style)

        buttons.first?.onTap = { [weak self] button in
            guard self?.delegate?.gameState == .running else { return }
            self?.getPlayers()?.currentPlayerHits()
        }

        for i in 1..<buttons.count {
            buttons[i].onTap = { [weak self] button in
                guard self?.delegate?.gameState == .running else { return }
                self?.getPlayers()?.currentPlayerTapsWrongButton()
            }
        }
    }

    func lineOffset() -> CGFloat {
        guard let scene = self.scene, let view = scene.view else { return 0.0 }
        let maxInset = max(view.safeAreaInsets.top, view.safeAreaInsets.bottom)
        return CGFloat(self.style.numButtonLines) * (Style.buttonHeight + Style.buttonMargin) + maxInset
    }

    func node(named name: String, contact: SKPhysicsContact) -> SKNode? {
        if contact.bodyA.node?.name ?? "" == name { return contact.bodyA.node }
        if contact.bodyB.node?.name ?? "" == name { return contact.bodyB.node }
        return nil
    }
}

extension PongGameLogic {

    private func playerDidMiss(_ contact: SKPhysicsContact, playerIndex: Int) -> Bool {
        return node(named: NodeName.playerLineName[playerIndex], contact: contact) != nil
            && currentPlayer == playerIndex
    }

    public func didBegin(_ contact: SKPhysicsContact) {
        guard node(named: NodeName.problemName, contact: contact) != nil else { return }
        if playerDidMiss(contact, playerIndex: currentPlayer) {
            self.getPlayers()?.currentPlayerMisses()
        } else if node(named: NodeName.buttonLineName[currentPlayer], contact: contact) != nil {
            createButtons()
        }
    }
}
