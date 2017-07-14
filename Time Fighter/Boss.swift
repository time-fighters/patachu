//
//  Boss.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/13/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit

class Boss: SKSpriteNode, FireOn {
    
    var bossAtlas = SKTextureAtlas(named: "AztecBoss")
    var bossTextures = [SKTexture]()
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        super.init(texture: texture, color: color, size: size)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup()
    {
        
        
        for i in 1 ... bossAtlas.textureNames.count{
            let name = "BossIdle\(i)"
            bossTextures.append(bossAtlas.textureNamed(name))
        }
        
    }
    
    func animate(scene: SKScene) {
        self.run(SKAction.repeatForever(SKAction.animate(with: bossTextures, timePerFrame: 0.1)))    }
}
