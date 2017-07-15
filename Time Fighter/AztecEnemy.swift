//
//  AztecEnemy.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/15/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit

class AztecEnemy: SKSpriteNode {
    
    
    enum texturesAtlasTypes: String {
        case EnemyIdleAtlas
        case EnemyDieAtlas
    }
    
    let atlasNamesArray: [texturesAtlasTypes] = [.EnemyIdleAtlas, .EnemyDieAtlas,]
    var AtlasArray = [SKTextureAtlas]()
    var idleTextures = [SKTexture]()
    var dieTextures = [SKTexture]()
    
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
        
        atlasMap[.EnemyIdleAtlas] = SKTextureAtlas(named: "EnemyIdleAtlas")
        atlasMap[.EnemyDieAtlas] = SKTextureAtlas(named: "EnemyDieAtlas")
        for atlasType in atlasMap.keys
        {
            let atlas = atlasMap[atlasType]!
            switch atlasType {
                
            case .EnemyIdleAtlas:
                
                for i in 1 ... atlas.textureNames.count{
                    let idleTextureName = "EnemyIdle\(i)"
                    idleTextures.append(atlas.textureNamed(idleTextureName))
                }
                
            case .EnemyDieAtlas:
                
                for j in 1 ... atlas.textureNames.count{
                    let dieTextureName = "EnemyDeado\(j)"
                    dieTextures.append(atlas.textureNamed(dieTextureName))
                }
                
            default:
                break
                
            }
        }
        
    }
    
    func animateIdle(scene: SKScene) {
        
        self.removeAllActions()
        
        self.run(SKAction.repeatForever(SKAction.animate(with: idleTextures, timePerFrame: 0.1)))
    }
    func animateDie(scene: SKScene)  {
        
        self.run(SKAction.repeatForever(SKAction.animate(with: dieTextures, timePerFrame: 0.2)))
    }
    
}
