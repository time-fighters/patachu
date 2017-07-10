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
    
    
    public init(scene:SKScene, initialPosition:CGPoint) {
        self.groundShape = SKShapeNode()
        var splinePoints = [CGPoint(x: initialPosition.x, y: initialPosition.y),
                            CGPoint(x: 22, y: -276),
                            CGPoint(x: 400, y: 110),
                            CGPoint(x: 640, y: 20)]
         self.groundShape = SKShapeNode(splinePoints: &splinePoints,
                                 count: splinePoints.count)
        //self.groundShape.path = UIBezierPath(roundedRect: CGRect(x: -128, y: -128, width: 256, height: 256), cornerRadius: 64).cgPath
        self.groundShape.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        //self.groundShape.fillColor = UIColor.red
        self.groundShape.strokeColor = UIColor.blue
        self.groundShape.lineWidth = 10
        self.groundShape.zPosition = 7
        scene.addChild(self.groundShape)
        
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
