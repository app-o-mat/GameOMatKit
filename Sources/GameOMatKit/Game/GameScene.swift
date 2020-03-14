//
//  GameScene.swift
//  MathOMat
//
//  Created by Louis Franco on 12/21/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit

open class GameScene: SKScene {

    open var gameLogic: GameLogic {
        didSet {
            didSetGameLogic()
        }
    }
    let gameLogics: [GameLogic]

    public let gameNodeRoot = SKEffectNode()
    public private(set) var buttonNodeRoot: SKNode?

    var startButton: ColorButtonNode?
    var pauseButton: ColorButtonNode?
    var themeButton: ColorButtonNode?
    var resetButton: ColorButtonNode?

    var playerButtons = [ColorButtonNode]()
    var optionButtons = [ColorButtonNode]()

    var numPausesLeft = 3

    let tapRecognizer = UILongPressGestureRecognizer()

    var backgroundIndex = 0 {
        didSet {
            UserDefaults.standard.set(backgroundIndex, forKey: SettingKey.backgroundIndex)
            self.backgroundColor = AppColor.boardBackground[backgroundIndex]
        }
    }

    var numberOfPlayers = 2 {
        didSet {
            didSetNumberOfPlayer()
        }
    }

    open var gameState = GameState.waitingToStart

    public init(size: CGSize, gameLogics: [GameLogic]) {
        self.backgroundIndex = UserDefaults.standard.integer(forKey: SettingKey.backgroundIndex)

        let storedNumberOfPlayers = UserDefaults.standard.integer(forKey: SettingKey.numberOfPlayers)
        self.numberOfPlayers = (storedNumberOfPlayers > 0) ? storedNumberOfPlayers : 2
        self.gameLogics = gameLogics
        self.gameLogic = gameLogics[numberOfPlayers - 1]

        super.init(size: size)

        didSetGameLogic()

        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.backgroundColor = AppColor.boardBackground[backgroundIndex]

        self.gameNodeRoot.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 5])
        self.gameNodeRoot.shouldEnableEffects = true
        self.addChild(self.gameNodeRoot)

        let buttonNodeRoot = SKNode()
        self.buttonNodeRoot = buttonNodeRoot
        self.addChild(buttonNodeRoot)

        subscribeToAppEvents()
        tapRecognizer.addTarget(self, action: #selector(onTap(tap:)))
        tapRecognizer.minimumPressDuration = 0
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open func didSetGameLogic() {
        self.gameLogic.delegate = self
        self.physicsWorld.contactDelegate = self.gameLogic
    }

    open func didSetNumberOfPlayer() {
        UserDefaults.standard.set(numberOfPlayers, forKey: SettingKey.numberOfPlayers)
        resetPlayerButtons()
        self.gameLogic.removeAllNodes()
        self.gameLogic = self.gameLogics[self.numberOfPlayers - 1]
        createGameBoard()
    }

    // App Events
    private func subscribeToAppEvents() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appBecameActive),
                                       name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(appResignActive),
                                       name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func appBecameActive() {
        if self.gameState != .waitingToStart {
            pauseGame()
            removeControlButtons()
            addStartButton()
        }
    }

    @objc private func appResignActive() {
        if self.gameState != .waitingToStart {
            pauseGame()
        }
    }

    // Tap recognizer
    @objc private func onTap(tap: UIGestureRecognizer) {
        guard let view = self.view else { return }
        if tap.state == .began {
            var point = tap.location(in: view)
            point.y = view.bounds.height - point.y
            for node in self.nodes(at: point) {
                if let button = node as? ColorButtonNode {
                    button.onTap?(button)
                }
            }
        }
    }

    // Game lifecycle
    open func startGame(view: UIView) {
        createGameBoard()
        addWaitingToStartButtons()
        view.addGestureRecognizer(self.tapRecognizer)
    }

    open func addWaitingToStartButtons() {
        removeControlButtons()
        addStartButton()
        addThemeButton()
        addPlayerButtons()
    }

    open func createGameBoard() {
        gameLogic.addBoardNodes()
    }

    open func removeControlButtons() {
        self.pauseButton?.removeFromParent()
        self.pauseButton = nil
        self.startButton?.removeFromParent()
        self.startButton = nil
        self.themeButton?.removeFromParent()
        self.themeButton = nil
        self.resetButton?.removeFromParent()
        self.resetButton = nil
        removePlayerButtons()
    }

    public func buttonPosition(xGridOffset: CGFloat, yGridOffset: CGFloat) -> CGPoint {
        return CGPoint(x: self.size.width / 2 + (Style.bigButtonSize.width / 2 + 10) * xGridOffset,
                       y: self.size.height / 2 + (Style.bigButtonSize.height / 2 + 10) * yGridOffset)
    }

    func addStartButton() {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.bigButtonSize)
        self.startButton = button
        self.buttonNodeRoot?.addChild(button)
        button.zPosition = Style.buttonZPosition
        button.texture = SKTexture(imageNamed: "play-button")
        button.position = buttonPosition(xGridOffset: 0, yGridOffset: 2)
        button.onTap = { [weak self] button in
            self?.onStartTapped()
        }
    }

    func addThemeButton() {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.smallButtonSize)
        self.themeButton = button
        self.buttonNodeRoot?.addChild(button)
        button.zPosition = Style.buttonZPosition
        button.texture = SKTexture(imageNamed: "theme-button")
        button.position = buttonPosition(xGridOffset: 0, yGridOffset: -3.5)
        button.onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.backgroundIndex =  (sself.backgroundIndex + 1) % AppColor.boardBackground.count
        }
    }

    func addResetButton() {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.smallButtonSize)
        self.resetButton = button
        self.buttonNodeRoot?.addChild(button)
        button.zPosition = Style.buttonZPosition
        button.texture = SKTexture(imageNamed: "reset-button")
        button.position = buttonPosition(xGridOffset: 1.5, yGridOffset: 2)
        button.onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.reset()
        }
    }

    func addOptionButtons() {
        let playerIndex = numberOfPlayers - 1
        let options = gameLogics[playerIndex].options()
        let playerX = playerXGridOffset(playerIndex: playerIndex)
        let playerY = playerYGridOffset(playerIndex: playerIndex)
        let spacing: CGFloat = 0.6
        let startXOffset: CGFloat =  -spacing * CGFloat(options.options.count - 1) / 2.0
        let yOffset: CGFloat = -0.80

        for (i, option) in options.options.enumerated() {
            let xOffset = startXOffset + CGFloat(i) * spacing

            let yGridOffset: CGFloat = -sqrt(pow(yOffset, 2) - pow(xOffset, 2))
            let pos = buttonPosition(xGridOffset: playerX + xOffset, yGridOffset: playerY + yGridOffset)
            self.optionButtons.append(
                addOptionButton(option: option, position: pos, on: option.on))
        }
    }

    func addOptionButton(option: GameOption, position: CGPoint, on: Bool) -> ColorButtonNode {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.miniButtonSize)
        self.buttonNodeRoot?.addChild(button)
        button.zPosition = Style.buttonZPosition
        button.texture = SKTexture(imageNamed: "\(option.buttonImagePrefix)-button-\(on ? "on" : "off")")
        button.position = position
        button.name = name
        button.onTap = { [weak self, weak option] _ in
            guard let sself = self, let option = option else { return }
            sself.gameLogic.options().tap(option: option)
            sself.resetOptionButtons()
        }
        return button
    }

    func removeOptionButtons() {
        self.optionButtons.forEach { $0.removeFromParent() }
        self.optionButtons = []
    }

    func resetOptionButtons() {
        removeOptionButtons()
        addOptionButtons()
    }

    func playerXGridOffset(playerIndex: Int) -> CGFloat {
        return -1 + CGFloat(playerIndex) * 2
    }

    func playerYGridOffset(playerIndex: Int) -> CGFloat {
        return -2
    }

    func addPlayerButtons() {
        for (i, player) in ["1p", "2p"].enumerated() {
            let pos = buttonPosition(xGridOffset: playerXGridOffset(playerIndex: i),
                                     yGridOffset: playerYGridOffset(playerIndex: i))
            self.playerButtons.append(
                addPlayerButton(name: player, position: pos, on: numberOfPlayers == (i+1)))
        }
        addOptionButtons()
    }

    func addPlayerButton(name: String, position: CGPoint, on: Bool) -> ColorButtonNode {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.smallButtonSize)
        self.buttonNodeRoot?.addChild(button)
        button.zPosition = Style.buttonZPosition
        button.texture = SKTexture(imageNamed: "\(name)-button-\(on ? "on" : "off")")
        button.position = position
        button.name = name
        button.onTap = { [weak self] _ in
            guard let numberOfPlayers = Int(String(name.prefix(1))) else { return }
            self?.numberOfPlayers = numberOfPlayers
        }
        return button
    }

    func resetPlayerButtons() {
        removePlayerButtons()
        addPlayerButtons()
    }

    func removePlayerButtons() {
        self.playerButtons.forEach { $0.removeFromParent() }
        self.playerButtons = []
        removeOptionButtons()
    }

    open func onStartTapped() {
        if self.gameState == .paused {
            unPauseGame()
        } else if self.gameState == .waitingToStart {
            createRunningGameBoard()
        }
        addPauseButton()
    }

    func addPauseButton() {
        removeControlButtons()

        guard numPausesLeft > 0 else { return }

        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.bigButtonSize)
        self.pauseButton = button
        self.buttonNodeRoot?.addChild(button)
        button.texture = SKTexture(imageNamed: "pause-button")
        button.alpha = 0.4
        button.position = buttonPosition(xGridOffset: 0, yGridOffset: 2)
        button.onTap = { [weak self] button in
            self?.onPauseTapped()
        }
    }

    func hidePauseButton() {
        self.pauseButton?.isHidden = true
    }

    func showPauseButton() {
        guard numPausesLeft > 0 else { return }
        self.pauseButton?.isHidden = false
    }

    open func onPauseTapped() {
        numPausesLeft -= 1
        pauseGame()
        removeControlButtons()
        addStartButton()
        addResetButton()
    }

    open func createRunningGameBoard() {
        self.numPausesLeft = 3
        gameLogic.reset()
        gameLogic.run()
        self.gameState = .running
        self.gameNodeRoot.shouldEnableEffects = false
    }

    open func reset() {
        unPauseGame()
        gameLogic.gameOver()
    }

    func pauseGame() {
        self.gameState = .paused
        self.isPaused = true
        self.gameNodeRoot.shouldEnableEffects = true
    }

    func unPauseGame() {
        self.gameState = .running
        self.isPaused = false
        self.gameNodeRoot.shouldEnableEffects = false
    }

}

extension GameScene: GameLogicDelegate {
    open func didGameOver() {
        addWaitingToStartButtons()
        self.gameState = .waitingToStart
        self.gameNodeRoot.shouldEnableEffects = true
    }

    open func scene() -> GameScene {
        return self
    }
}
