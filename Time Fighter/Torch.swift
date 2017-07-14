//
//  Torch.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/13/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit

class Torch: SKSpriteNode, FireOn {
    
    var fireAtlas = SKTextureAtlas(named: "LampAtlas")
    var fireTextures = [SKTexture]()
    
    
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
        
        
        for i in 1 ... fireAtlas.textureNames.count{
            let name = "Lamp\(i)"
            fireTextures.append(fireAtlas.textureNamed(name))
        }
        
    }
    
    func animate(scene: SKScene) {
        self.run(SKAction.repeatForever(SKAction.animate(with: fireTextures, timePerFrame: 0.1)))    }
}
