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
    var groundShape: SKShapeNode
    
    public init(scene:SKScene) {
        self.groundShape = SKShapeNode()
        var points = [CGPoint(x: 4253, y: -231),
                            CGPoint(x: 4896, y: 111),
                            CGPoint(x: 6130, y: 111),
                            CGPoint(x: 6829, y: -264)]
        self.groundShape = SKShapeNode(points: &points,
                                                             count: points.count)
   
        self.groundShape.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
    
        self.groundShape.zPosition = 0
        self.groundShape.physicsBody?.categoryBitMask = GameElements.ground
        self.groundShape.physicsBody?.collisionBitMask = GameElements.mainCharacter | GameElements.enemy
        self.groundShape.physicsBody?.contactTestBitMask = GameElements.bullet | GameElements.mainCharacter
        //self.groundShape.alpha = 0
        self.groundShape.strokeColor = .blue
        self.groundShape.lineWidth = 7
        
        scene.addChild(self.groundShape)
        
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
