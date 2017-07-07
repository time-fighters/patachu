//
//  BackgroundParallax.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/1/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit


public class BackgroundParallax: SKNode {
    
    var currentSprite: SKSpriteNode
    var nextSprite: SKSpriteNode
    
    public init(spriteName: String) {
        self.currentSprite = SKSpriteNode(imageNamed: spriteName)
        self.nextSprite = self.currentSprite.copy() as! SKSpriteNode
    
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///   - speed: Speed of left moviment
    public func moveSprite(withSpeed speed: Float, deltaTime: TimeInterval, scene: SKScene) -> Void {
        var newPosition = CGPoint.zero
        
        // For both the sprite and its duplicate:
        for spriteToMove in [currentSprite, nextSprite] {
            
            // Shift the sprite leftward based on the speed
            newPosition = spriteToMove.position
            newPosition.x -= CGFloat(speed * Float(deltaTime))
            spriteToMove.position = newPosition
            
            // If this sprite is now offscreen (i.e., its rightmost edge is
            // farther left than the scene's leftmost edge):
            if spriteToMove.frame.maxX < scene.frame.minX {
                
                // Shift it over so that it's now to the immediate right
                // of the other sprite.
                // This means that the two sprites are effectively
                // leap-frogging each other as they both move.
                spriteToMove.position =
                    CGPoint(x: spriteToMove.position.x +
                        spriteToMove.size.width * 2,
                            y: spriteToMove.position.y)
            }
            
        }
    }
    
    
    /// Set the configuration for spriteNode and add it on Scene Background
    ///
    /// - Parameters:
    ///   - sprite: Sprite to configurate
    ///   - zpostion: Position on z axes on the scene
    ///   - anchorPoint: anchor point of sprite
    ///   - screenPosition: Desired postion to set on screen
    ///   - spriteSize: Sprite size value
    public  func createBackgroundNode(zpostion: CGFloat, anchorPoint: CGPoint, screenPosition:CGPoint, spriteSize: CGSize, scene:SKScene) {

        //set z position of sprite
        currentSprite.zPosition = zpostion
        //Set the anchor point
        currentSprite.anchorPoint = anchorPoint
        //Set the sprite position
        currentSprite.position = screenPosition
        currentSprite.size = spriteSize
        scene.addChild(currentSprite)
        
        nextSprite = (currentSprite.copy() as? SKSpriteNode)!
        nextSprite.position = CGPoint(x: screenPosition.x + (currentSprite.size.width), y: screenPosition.y)
        scene.addChild(nextSprite)
        
    }
    
}


