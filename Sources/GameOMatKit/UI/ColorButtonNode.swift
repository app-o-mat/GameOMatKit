//
//  ColorButtonNode.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import SpriteKit

public class ColorButtonNode: SKSpriteNode {
    private let labelNode = SKLabelNode()
    private let flipped: Bool
    public var onTap: ((ColorButtonNode) -> Void)?

    public var text: String? {
        get { return labelNode.text }
        set {
            labelNode.text = newValue
            updateText()
        }

    }

    public init(color: UIColor, size: CGSize, flipped: Bool = false, fontSize: CGFloat = Style.buttonFontSize) {
        self.flipped = flipped
        super.init(texture: nil, color: color, size: size)
        self.isUserInteractionEnabled = true
        addChild(labelNode)
        labelNode.fontSize = fontSize
        labelNode.fontName = Style.fontName
        if flipped {
            labelNode.zRotation = .pi
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateText() {
        if flipped {
            labelNode.position = CGPoint(x: 0, y: labelNode.frame.size.height / 2.0)
        } else {
            labelNode.position = CGPoint(x: 0, y: -(labelNode.frame.size.height) / 2.0)
        }
    }
}
