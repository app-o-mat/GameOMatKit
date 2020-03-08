//
//  Constants.swift
//  MathOMat
//
//  Created by Louis Franco on 12/21/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import SpriteKit

public enum Style {
    public static let fontName = "Courier"
    public static let scoreFontSize: CGFloat = 50
    public static let problemFontSize: CGFloat = 54
    public static let buttonFontSize: CGFloat = 24
    public static let buttonFont = UIFont(name: Style.fontName, size: Style.buttonFontSize)
    public static let bigButtonSize = CGSize(width: 132, height: 132)
    public static let smallButtonSize = CGSize(width: 66, height: 66)
    public static let miniButtonSize = CGSize(width: 44, height: 44)

    public static let sideInset: CGFloat = 5
    public static let boundaryLineWidth: CGFloat = 5
    public static let guideLineWidth: CGFloat = 2
    public static let buttonHeight: CGFloat = 44
    public static let buttonMargin: CGFloat = 10
    public static let buttonZPosition: CGFloat = 1
}

public enum NodeName {
    public static let problemName = "problem"
    public static let playerLineName = ["player1line", "player2line"]
    public static let buttonLineName = ["button1line", "button2line"]
}

public enum SettingKey {
    public static let prefix = "settingKey"
    public static let backgroundIndex = "\(prefix).backgroundIndex"
    public static let numberOfPlayers = "\(prefix).numberOfPlayers"
}

public enum GameState {
    case waitingToStart
    case running
    case paused
}
