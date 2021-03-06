//
//  Colors.swift
//  MathOMat
//
//  Created by Louis Franco on 12/9/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit

public class RandomColors {

    let hues: [CGFloat] = (0..<37).map { (i: Int) in CGFloat(1.0 / 35.0) * CGFloat(i) }
    var currentHue = 0

    public func nextHue() -> CGFloat {
        defer {
            currentHue = (currentHue + 5) % hues.count
        }
        return hues[currentHue]
    }

    public func nextColor() -> UIColor {
        return UIColor.init(
            hue: nextHue(),
            saturation: 0.75, brightness: 0.5, alpha: 1.0)
    }

}

public enum AppColor {
    public static let problemBackground = UIColor.clear

    public static let boardBackground =
        [UIColor(hue: 0.0, saturation: 0.0, brightness: 0.2, alpha: 1.0),
         UIColor(hue: 0.75, saturation: 0.50, brightness: 0.5, alpha: 1.0),
         UIColor(hue: 0.95, saturation: 0.50, brightness: 0.75, alpha: 1.0),
         UIColor(hue: 0.05, saturation: 0.50, brightness: 0.75, alpha: 1.0),
         UIColor(hue: 0.5, saturation: 0.50, brightness: 0.5, alpha: 1.0),
         UIColor(hue: 0.25, saturation: 0.50, brightness: 0.5, alpha: 1.0),
         UIColor(hue: 0.15, saturation: 0.50, brightness: 0.75, alpha: 1.0),
         ]
    public static let imageButtonBackground = UIColor.clear

    public static let boundaryColor = UIColor.white
    public static let guideColor = UIColor.white
}
