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
        case ShootArmAtlas
        case idleOrWalkArmAtlas
    }
    
    var armAtlasArray = [SKTextureAtlas]()
    var idleOrWalkTextures = [SKTexture]()
    var shootTextures = [SKTexture]()
    
    let atlasNamesArray: [texturesAtlasTypes] = [.ShootArmAtlas, .idleOrWalkArmAtlas]
    
    override var texture: SKTexture? {
        didSet {
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
        
        
        var atlasMap = [texturesAtlasTypes:SKTextureAtlas]()
        
        atlasMap[.idleOrWalkArmAtlas] = SKTextureAtlas(named: "idleOrWalkArmAtlas")
        atlasMap[.ShootArmAtlas] = SKTextureAtlas(named: "ShootArmAtlas")
        for atlasType in atlasMap.keys
        {
            let atlas = atlasMap[atlasType]!
            
            switch atlasType {
                
            case .idleOrWalkArmAtlas:
                for i in 1 ... atlas.textureNames.count{
                    let idleOrWalkTextureName = "ArmIdle\(i)"
                    idleOrWalkTextures.append(atlas.textureNamed(idleOrWalkTextureName))

                }
                
            case .ShootArmAtlas:
                
                for j in 1 ... atlas.textureNames.count{
                    let shootTextureName = "ArmShootingF\(j)"
                    shootTextures.append(atlas.textureNamed(shootTextureName))
                }
            }
        }

        self.zPosition = 6
        self.anchorPoint = CGPoint(x: 0.59, y: 0.5)
    }
    

    
    func animate(scene: SKScene, state: UInt32) {
        
        switch  state {

        case StateMachine.walk:
            self.run(SKAction.animate(with: idleOrWalkTextures, timePerFrame: 0.5))

        case StateMachine.idle:
            self.run(SKAction.animate(with: idleOrWalkTextures, timePerFrame: 0.5))

        case StateMachine.idleShoot():
            self.run(SKAction.repeatForever(SKAction.animate(with: shootTextures, timePerFrame: 0.1)))

        case StateMachine.walkShoot():
            self.run(SKAction.repeatForever(SKAction.animate(with: shootTextures, timePerFrame: 0.1)))

            
        default:
            print("x")
        }
    }
}
