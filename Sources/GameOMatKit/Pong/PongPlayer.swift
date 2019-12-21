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

    func buttonYPosition(viewSize: CGSize, buttonHeight: CGFloat, lineOffset: CGFloat) -> CGFloat {
        switch self {
        case .bottom:
            return lineOffset - 15.0 - buttonHeight / 2.0
        case .top:
            return viewSize.height - lineOffset + 15.0 + buttonHeight / 2.0
        }
    }
}

public class PongPlayer {
    public let problemRotation: CGFloat
    public let position: PlayerPosition
    public var velocity: CGFloat = 1.0
    public var score = 0

    let colors = RandomColors()
    var buttons = [ColorButtonNode]()

    public init(problemRotation: CGFloat, position: PlayerPosition) {
        self.problemRotation = problemRotation
        self.position = position
    }

    public func addButton(scene: SKScene, xPos: CGFloat, text: String, lineOffset: CGFloat) -> ColorButtonNode {
        let buttonWidth = lineOffset * 0.66
        let buttonSize = CGSize(width: lineOffset * 0.66, height: buttonWidth * 0.70)
        let button = ColorButtonNode(
            color: colors.nextColor(),
            size: buttonSize,
            flipped: position == .top)
        button.position =
            CGPoint(x: xPos,
                    y: position.buttonYPosition(viewSize: scene.size,
                                                buttonHeight: buttonSize.height,
                                                lineOffset: lineOffset))
        button.text = text
        scene.addChild(button)
        return button
    }

    public func addButtons(scene: SKScene, problem: Problem, lineOffset: CGFloat) -> [ColorButtonNode] {
        let buttonWidth: CGFloat = lineOffset * 0.66
        let possiblePositions: [CGFloat] = [scene.size.width / 2.0,
                                            scene.size.width / 2.0 - buttonWidth - 20,
                                            scene.size.width / 2.0 + buttonWidth + 20 ]
        let positions: [CGFloat] = GKRandomSource.sharedRandom()
            .arrayByShufflingObjects(in: possiblePositions).map { ($0 as? CGFloat) ?? 0.0 }
        let wrongAnswers = GKRandomSource.sharedRandom()
            .arrayByShufflingObjects(in: [String](problem.wrongAnswers))
            .map { ($0 as? String) ?? "" }

        self.buttons = [
            addButton(scene: scene, xPos: positions[0], text: problem.answer, lineOffset: lineOffset),
            addButton(scene: scene, xPos: positions[1], text: wrongAnswers[0], lineOffset: lineOffset),
            addButton(scene: scene, xPos: positions[2], text: wrongAnswers[1], lineOffset: lineOffset),
        ]
        return self.buttons
    }

    public func removeButtons() {
        self.buttons.forEach { $0.removeFromParent() }
    }
}