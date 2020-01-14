//
//  PongPlayer.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public enum PlayerPosition {
    case bottom
    case top

    func buttonYPosition(viewSize: CGSize, buttonHeight: CGFloat,
                         lineOffset: CGFloat, buttonLine: Int) -> CGFloat {
        switch self {
        case .bottom:
            return lineOffset - Style.buttonMargin - buttonHeight / 2.0 -
                (CGFloat(buttonLine) * buttonHeight + Style.buttonMargin)
        case .top:
            return viewSize.height - lineOffset + Style.buttonMargin + buttonHeight / 2.0 +
                (CGFloat(buttonLine) * buttonHeight + Style.buttonMargin)
        }
    }
}

public class PongPlayer: Player {
    public let problemRotation: CGFloat
    public let position: PlayerPosition
    public var velocity: CGFloat = 1.0
    public var score = 0 {
        didSet {
            scoreNode.text = "\(score)"
        }
    }
    public private(set) var scoreNode = SKLabelNode()

    let colors = RandomColors()
    var buttons = [ColorButtonNode]()

    public init(problemRotation: CGFloat, position: PlayerPosition) {
        self.problemRotation = problemRotation
        self.position = position
        self.scoreNode.text = "\(self.score)"
    }

    public func addButton(scene: SKScene, pos: CGPoint, text: String,
                          buttonWidth: CGFloat, fontSize: CGFloat)
        -> ColorButtonNode {

        let buttonSize = CGSize(width: buttonWidth, height: Style.buttonHeight)
        let button = ColorButtonNode(
            color: colors.nextColor(),
            size: buttonSize,
            flipped: position == .top,
            fontSize: fontSize)
        button.position = pos
        button.text = text
        scene.addChild(button)
        return button
    }

    func buttonPositions(scene: SKScene, lineOffset: CGFloat, buttonWidth: CGFloat, numButtonLines: Int) -> [CGPoint] {
        let yPos = position.buttonYPosition(viewSize: scene.size,
                                            buttonHeight: Style.buttonHeight,
                                            lineOffset: lineOffset,
                                            buttonLine: 0)

        let possiblePositions: [CGPoint]
        if numButtonLines == 1 {
            possiblePositions = [
                CGPoint(x: scene.size.width / 2.0, y: yPos),
                CGPoint(x: scene.size.width / 2.0 - buttonWidth - 20, y: yPos),
                CGPoint(x: scene.size.width / 2.0 + buttonWidth + 20, y: yPos),
            ]
        } else {
            let yPos2 = position.buttonYPosition(viewSize: scene.size,
                                                buttonHeight: Style.buttonHeight,
                                                lineOffset: lineOffset,
                                                buttonLine: 1)
            possiblePositions = [
                CGPoint(x: scene.size.width / 2.0, y: yPos),
                CGPoint(x: scene.size.width / 2.0 - buttonWidth / 2 - Style.buttonMargin, y: yPos2),
                CGPoint(x: scene.size.width / 2.0 + buttonWidth / 2 + Style.buttonMargin, y: yPos2),
            ]
        }
        return GKRandomSource.sharedRandom()
            .arrayByShufflingObjects(in: possiblePositions).compactMap { $0 as? CGPoint }
    }

    public func addButtons(scene: SKScene, problem: Problem,
                           lineOffset: CGFloat, buttonWidth: CGFloat,
                           style: PongStyle) -> [ColorButtonNode] {

        let positions = buttonPositions(scene: scene, lineOffset: lineOffset,
                                        buttonWidth: buttonWidth, numButtonLines: style.numButtonLines)
        let wrongAnswers = GKRandomSource.sharedRandom()
            .arrayByShufflingObjects(in: [String](problem.wrongAnswers))
            .compactMap { $0 as? String }

        self.buttons = [
            addButton(scene: scene, pos: positions[0], text: problem.answer,
                      buttonWidth: buttonWidth, fontSize: style.buttonFontSize),
            addButton(scene: scene, pos: positions[1], text: wrongAnswers[0],
                      buttonWidth: buttonWidth, fontSize: style.buttonFontSize),
            addButton(scene: scene, pos: positions[2], text: wrongAnswers[1],
                      buttonWidth: buttonWidth, fontSize: style.buttonFontSize),
        ]
        return self.buttons
    }

    public func removeButtons() {
        self.buttons.forEach { $0.removeFromParent() }
    }
}
