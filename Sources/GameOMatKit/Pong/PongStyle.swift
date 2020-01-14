//
//  File.swift
//  
//
//  Created by Louis Franco on 1/14/20.
//

import Foundation
import UIKit

public struct PongStyle {
    public let problemFontSize: CGFloat
    public let buttonFontSize: CGFloat
    public let numButtonLines: Int

    public init(problemFontSize: CGFloat = Style.problemFontSize,
                buttonFontSize: CGFloat = Style.buttonFontSize,
                numButtonLines: Int = 1) {
        self.problemFontSize = problemFontSize
        self.buttonFontSize = buttonFontSize
        self.numButtonLines = numButtonLines
    }
}
