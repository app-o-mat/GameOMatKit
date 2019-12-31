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

    var startButton: ColorButtonNode?
    var pauseButton: ColorButtonNode?
    var themeButton: ColorButtonNode?
    var resetButton: ColorButtonNode?

    var playerButtons = [ColorButtonNode]()

    var numPausesLeft = 3

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

        subscribeToAppEvents()
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

    open func startGame() {
        createGameBoard()
        addWaitingToStartButtons()
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
        addChild(button)
        button.texture = SKTexture(imageNamed: "play-button")
        button.position = buttonPosition(xGridOffset: 0, yGridOffset: 0)
        button.onTap = { [weak self] button in
            self?.onStartTapped()
        }
    }

    func addThemeButton() {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.smallButtonSize)
        self.themeButton = button
        addChild(button)
        button.texture = SKTexture(imageNamed: "theme-button")
        button.position = buttonPosition(xGridOffset: 1.5, yGridOffset: 0)
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
        addChild(button)
        button.texture = SKTexture(imageNamed: "reset-button")
        button.position = buttonPosition(xGridOffset: 1.5, yGridOffset: 0)
        button.onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.reset()
        }
    }

    func addPlayerButtons() {
        for (i, player) in ["1p", "2p"].enumerated() {
            let pos = buttonPosition(xGridOffset: -0.5 + CGFloat(i), yGridOffset: -1.5)
            self.playerButtons.append(
                addPlayerButton(name: player, position: pos, on: numberOfPlayers == (i+1)))

        }
    }

    func addPlayerButton(name: String, position: CGPoint, on: Bool) -> ColorButtonNode {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.smallButtonSize)
        addChild(button)
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
        addChild(button)
        button.texture = SKTexture(imageNamed: "pause-button")
        button.alpha = 0.4
        button.position = buttonPosition(xGridOffset: 0, yGridOffset: 0)
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
    }

    open func reset() {
        unPauseGame()
        gameLogic.gameOver()
    }

    func pauseGame() {
        self.gameState = .paused
        self.isPaused = true
    }

    func unPauseGame() {
        self.gameState = .running
        self.isPaused = false
    }

}

extension GameScene: GameLogicDelegate {
    open func didGameOver() {
        addWaitingToStartButtons()
        self.gameState = .waitingToStart
    }

    open func scene() -> GameScene {
        return self
    }
}