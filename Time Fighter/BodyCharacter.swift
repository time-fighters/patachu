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
        case walkBodyAtlas
        case idleBodyAtlas
        case jumpBodyAtlas
    }
    
    let atlasNamesArray: [texturesAtlasTypes] = [.idleBodyAtlas, .walkBodyAtlas, .jumpBodyAtlas]
    var AtlasArray = [SKTextureAtlas]()
    var idleTextures = [SKTexture]()
    var walkTextures = [SKTexture]()
    var jumpTextures = [SKTexture]()

    
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
        //key:value
        var atlasMap = [texturesAtlasTypes:SKTextureAtlas]()
        
        atlasMap[.idleBodyAtlas] = SKTextureAtlas(named: "idleBodyAtlas")
        atlasMap[.walkBodyAtlas] = SKTextureAtlas(named: "walkBodyAtlas")
        for atlasType in atlasMap.keys
        {
            let atlas = atlasMap[atlasType]!
            switch atlasType {
                
            case .idleBodyAtlas:
                
                for i in 1 ... atlas.textureNames.count{
                    let idleTextureName = "MercIdle\(i)"
                    idleTextures.append(atlas.textureNamed(idleTextureName))
                }
            
            case .walkBodyAtlas:
                
                for j in 1 ... atlas.textureNames.count{
                    let walkTextureName = "MercWalk\(j)"
                    walkTextures.append(atlas.textureNamed(walkTextureName))
                }
     
            default:
                break
                
            }
        }

    }
    
    func animate(scene: SKScene, state:UInt32) {
        
        switch  state {
        case StateMachine.idle:
            
           self.run(SKAction.repeatForever(SKAction.animate(with: idleTextures, timePerFrame: 0.5)))
            
        case StateMachine.walk:
            
            self.run(SKAction.repeatForever(SKAction.animate(with: walkTextures, timePerFrame: 0.1)))
            
        case StateMachine.idleShoot():
            
                self.run(SKAction.animate(with: [idleTextures[0]], timePerFrame: 0.1))
            
            
        case StateMachine.walkShoot():
            self.run(SKAction.repeatForever(SKAction.animate(with: walkTextures, timePerFrame: 0.1)))
            
        default:
            
            
            break
        }
        
    }
    
    
}
