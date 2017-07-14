//
//  Ground.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/10/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit


class Ground: SKShapeNode {
    let stairs = SKTexture(imageNamed: "Stairs")
    var points = [CGPoint(x: 4187, y: -264),
                  CGPoint(x: 4275, y: -264),
                  CGPoint(x: 4896, y: 111),
                  CGPoint(x: 6130, y: 111),
                  CGPoint(x: 6829, y: -264),
                  CGPoint(x: 4187, y: -264)]
    
    public init(scene:SKScene) {
        var groundShape = SKSpriteNode(texture: stairs)
        
        let path = CGMutablePath()
        path.addLines(between: [self.points[0], self.points[1], self.points[2],self.points[3], self.points[4],self.points[5]])
            
        path.closeSubpath()

        groundShape.zPosition = 0
        groundShape.physicsBody = SKPhysicsBody(polygonFrom: path)
        groundShape.physicsBody?.affectedByGravity = false
        groundShape.physicsBody?.allowsRotation = false
        groundShape.physicsBody?.angularDamping = 0
        groundShape.physicsBody?.friction = 0.8
        groundShape.physicsBody?.angularVelocity = 0
        groundShape.physicsBody?.isDynamic = false
        groundShape.physicsBody?.categoryBitMask = GameElements.ground
        groundShape.physicsBody?.collisionBitMask = GameElements.mainCharacter | GameElements.enemy
        groundShape.physicsBody?.contactTestBitMask = GameElements.bullet | GameElements.mainCharacter
        groundShape.alpha = 0
        groundShape.position = CGPoint.zero
        scene.addChild(groundShape)
        
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
