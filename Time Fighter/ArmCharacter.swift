//
//  ArmCharacter.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/5/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit

class ArmCharacter: SKSpriteNode, Animate {
    
    enum texturesAtlasTypes: String {
        case shootArmAtlas
        case idleArmAtlas
        case walkArmAtlas
    }
    
    var armAtlasArray = [SKTextureAtlas]()
    //    var walkTextures:[SKTexture]
    var idleTextures = [SKTexture]()
    //    var jumpTextures:[SKTexture]
    
    let atlasNamesArray: [texturesAtlasTypes] = [.idleArmAtlas, .walkArmAtlas, .shootArmAtlas]
    
    override var texture: SKTexture? {
        didSet {
            print(" Aqui!! \(self.texture) \(self) \(self.parent)")
        }
    }

    
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
        self.scale(to: CGSize(width: 100 , height: 50))
        
        var atlasMap = [texturesAtlasTypes:SKTextureAtlas]()
        
        atlasMap[.idleArmAtlas] = SKTextureAtlas(named: "idleArmAtlas")
        for atlasType in atlasMap.keys
        {
            let atlas = atlasMap[atlasType]!
            switch atlasType {
                
            case .idleArmAtlas:
                
                for j in 0 ..< atlas.textureNames.count{
                    
                    idleTextures.append(SKTexture(imageNamed: atlas.textureNames[j]))
                }
                
            default:
                break
                
            }
        }
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint(x: 0, y: 0)
        self.zPosition = 6
        //self.texture = SKTexture(imageNamed: "Arm")
        self.texture = SKTexture(imageNamed: "\(idleTextures[0])")
        //self.size = (self.texture?.size())!
        
    }
    
    
    func animate(scene: SKScene, state: UInt32) {
        
        switch  state {
        case StateMachine.idle:
            
            //self.texture = SKTexture(imageNamed: "Arm")
            self.run(SKAction.animate(with: idleTextures, timePerFrame: 0.1))


        case StateMachine.walk:
            
            print("x")
            
            
            
        default:
            
            print("x")
        }
    }
    
    
}
