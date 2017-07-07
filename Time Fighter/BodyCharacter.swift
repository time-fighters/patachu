//
//  BodyCharacter.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/5/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit

class BodyCharacter: SKSpriteNode, Animate {
    
    
    enum texturesAtlasTypes: String {
        case walkAtlas
        case idleAtlas
        case jumpAtlas
    }
    
    let atlasNamesArray: [texturesAtlasTypes] = [.idleAtlas, .walkAtlas, .jumpAtlas]
    var AtlasArray = [SKTextureAtlas]()
    var idleTextures = [SKTexture]()


    
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
        var atlasMap = [texturesAtlasTypes:SKTextureAtlas]()
        
        atlasMap[.idleAtlas] = SKTextureAtlas(named: "idleAtlas")
        for atlasType in atlasMap.keys
        {
            let atlas = atlasMap[atlasType]!
            switch atlasType {
                
            case .idleAtlas:
                
                for j in 0 ..< atlas.textureNames.count{
                    
                    idleTextures.append(SKTexture(imageNamed: atlas.textureNames[j]))
                }
     
            default:
                break
                
            }
        }
        self.texture = SKTexture(imageNamed: "\(idleTextures[0])")
        self.zPosition = 5
        self.position = CGPoint.zero
        self.size = (self.texture?.size())!
    }
    
    func animate(scene: SKScene, state:UInt32) {
        
        switch  state {
        case StateMachine.idle:
            
           self.run(SKAction.repeatForever(SKAction.animate(with: idleTextures, timePerFrame: 0.1)))
            
            break
        case StateMachine.walk:
            
            break
         
        default:
            
            
            break
        }
        
    }
    
    
}
