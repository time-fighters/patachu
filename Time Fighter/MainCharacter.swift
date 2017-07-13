//
//  MainCharacter.swift
//  Time Fighter
//
//  Created by Wilson Martins on 28/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import Foundation
import SpriteKit

enum DirectionEnum {
    case left
    case right
}

protocol NodeInformation {
    func setDirection(_ direction: DirectionEnum)
    func isShooting(_ isShooting: Bool, status: JoystickStatusEnum)
}

class MainCharacter: SKSpriteNode, JoystickController, Update, NodeInformation {
    
    let VELOCITY: CGFloat = 7
    var xVelocity: Double = 0
    var yVelocity: Double = 0
    var body: BodyCharacter!
    var arm: ArmCharacter!
    var isJumping: Bool = false
    var isShooting: Bool = false

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
        self.xVelocity = Double(self.VELOCITY * cos(angularVelocity))
        self.yVelocity = Double(self.VELOCITY * sin(angularVelocity))
    }
    
    func runAnimations(scene: SKScene,  state: UInt32  ) {
        body.animate(scene: scene, state: state)
        arm.animate(scene: scene, state: state)
    }
    
    func configureStateMachine(forStatus status: JoystickStatusEnum) {
        
        print("Joystick: \(status)\nState: \(state)\nxV: \(xVelocity)\nyVelocity: \(yVelocity)")

        switch status {

        case .running:
            let shouldWalk = xVelocity != 0
            let shouldJump = yVelocity >= 4

            //current state of mainCharacter
            switch state {
            case StateMachine.idle:
                if shouldWalk{
                    state = StateMachine.walk
                }else if shouldJump{
                    state = StateMachine.jump
                }else if isShooting{
                    state = StateMachine.shoot
                }
            case StateMachine.walk:
                if isShooting {
                    state = StateMachine.walkShoot()
                }else if shouldJump {
                    state = StateMachine.jump
                }
            case StateMachine.jump:
                if isShooting{
                    state = StateMachine.jumpShoot()
                }
            case StateMachine.shoot:
                if isJumping || shouldJump {
                    state = StateMachine.jumpShoot()
                }else if shouldWalk{
                    state = StateMachine.walkShoot()
                }
                
            default:
                break
            }
        
        case .finished:
            switch state {
            case StateMachine.walk, StateMachine.jump, StateMachine.shoot:
                  state = StateMachine.idle
            case StateMachine.jumpShoot():
                if isShooting{
                    state = StateMachine.shoot
                }else {
                    state = StateMachine.jump
                }
            case StateMachine.walkShoot():
                if isShooting{
                    state = StateMachine.shoot
                }else {
                    state = StateMachine.walk
                }
                
            default:
                break
            }

        default:
            break
            
        }
      
    }

    func update(_ currentTime: TimeInterval) {
        
        switch state {
        case StateMachine.walk, StateMachine.walkShoot():
            self.run(SKAction.move(by: CGVector(dx: self.xVelocity, dy: 0), duration: 1))
        case StateMachine.jump, StateMachine.jumpShoot():
            if !isJumping{
                isJumping = true
                self.physicsBody?.velocity.dy = CGFloat(self.yVelocity*100)
            }
        default:
            break
        }
        
        
//            currentStatus = .finished
        
        
        self.arm.position = CGPoint(x: self.body.position.x, y: self.body.position.y)
    }
    
    func setDirection(_ direction: DirectionEnum) {
        if (direction == .left) {
            self.xScale = -1
        } else if (direction == .right) {
            self.xScale = 1
        }
    }
    
    func isShooting(_ isShooting: Bool, status: JoystickStatusEnum) {
        self.isShooting = isShooting
        configureStateMachine(forStatus: status)
    }
    

}

