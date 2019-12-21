//
//  SKPhysicsBody+Categories.swift
//  
//
//  Created by Louis Franco on 12/21/19.
//

import Foundation
import SpriteKit
import GameplayKit

public extension SKNode {

    static let categoryObject: UInt32 = 0b0001
    static let categoryGuide: UInt32 = 0b0010

    func setupAsGuide() {
        self.physicsBody?.setupAsGuide()
    }

    func setupAsObject() {
        self.physicsBody?.setupAsObject()
    }

    func setupAsBoundary() {
        self.physicsBody?.setupAsBoundary()
    }
}

public extension SKPhysicsBody {

    func setupAsGuide() {
        self.categoryBitMask = SKNode.categoryGuide
        self.collisionBitMask = SKNode.categoryGuide
    }

    func setupAsObject() {
        self.categoryBitMask = SKNode.categoryObject
        self.collisionBitMask = SKNode.categoryObject
    }

    func setupAsBoundary() {
        self.restitution = 1.0
        self.isDynamic = false
        self.friction = 0
        self.usesPreciseCollisionDetection = true
    }

}
