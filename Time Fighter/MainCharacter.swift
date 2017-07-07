//
//  MainCharacter.swift
//  Time Fighter
//
//  Created by Wilson Martins on 28/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import Foundation
import SpriteKit



//enum CharacterState {
//    case IDLE
//}
class MainCharacter: SKSpriteNode, JoystickDirection {
    
    let MAX_VELOCITY: CGFloat = 400.0
    let ACCELERATION: CGFloat = 3.0
    var body: BodyCharacter!
    var arm: ArmCharacter!
    let stateMachine:StateMachine = StateMachine()
    
       var state: UInt32 = StateMachine.idle  {
        didSet{
            self.runAnimations(scene: scene!, state: state)
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
        self.body = self.childNode(withName: "body") as? BodyCharacter
        self.arm = self.childNode(withName: "arm") as! ArmCharacter
        
        
    }
    
    func joystickInteraction(velocity: CGVector, angularVelocity: CGFloat) {
        self.physicsBody?.velocity = CGVector(dx: ACCELERATION * copysign(CGFloat.minimumMagnitude(self.MAX_VELOCITY, abs(velocity.dx)), velocity.dx), dy: ACCELERATION * copysign(CGFloat.minimumMagnitude(self.MAX_VELOCITY, abs(velocity.dy)), velocity.dy))
    }
    
     func runAnimations(scene: SKScene,  state: UInt32  ) {
        body.animate(scene: scene, state: state)
        arm.animate(scene: scene, state: state)
        
        }
    }
    


