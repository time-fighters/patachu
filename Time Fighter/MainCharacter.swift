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

    func isShooting(_ isShooting: Bool)
}

class MainCharacter: SKSpriteNode, JoystickController, Animate, Update, NodeInformation {

    let VELOCITY: CGFloat = 7
    var xVelocity: Double = 0
    var yVelocity: Double = 0
    var body: BodyCharacter!
    var arm: ArmCharacter!
    var isShooting: Bool = false
    var isJumping: Bool = false
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
        self.xVelocity = Double(self.VELOCITY * cos(angularVelocity))
        self.yVelocity = Double(self.VELOCITY * sin(angularVelocity))
    }
    
     func runAnimations(scene: SKScene,  state: UInt32  ) {
        body.animate(scene: scene, state: state)
        arm.animate(scene: scene, state: state)
    }

    func status(status: JoystickStatusEnum) {
        if (!self.isShooting) {
            if ((status == .started || status == .running) && self.yVelocity >= 3 && !self.isJumping) {
                self.state = StateMachine.jump
                self.isJumping = true
            } else if (status == .started || status == .running) {
                self.state = StateMachine.walk
            } else if (status == .finished) {
                self.state = StateMachine.idle
            }
        } else {
            if ((status == .started || status == .running) && self.yVelocity >= 3 && !self.isJumping) {
                self.state = StateMachine.jump
                self.isJumping = true
            } else if (status == .started || status == .running) {
                self.state = StateMachine.walkShoot()
            } else if (status == .finished) {
                self.state = StateMachine.idleShoot()
            }
        }
    }

    func animate(scene: SKScene, state: UInt32 ) {}

    func update(_ currentTime: TimeInterval) {
        if (self.state == StateMachine.walk || self.state == StateMachine.jump) {
            self.run(SKAction.move(by: CGVector(dx: self.xVelocity, dy: 0), duration: 1))
        }

        if (self.state == StateMachine.jump) {
            self.physicsBody?.velocity.dy = 700
        }

        self.arm.position = CGPoint(x: self.body.position.x, y: self.body.position.y)
    }

    func setDirection(_ direction: DirectionEnum) {
        if (direction == .left) {
            self.xScale = -1
        } else if (direction == .right) {
            self.xScale = 1
        }
    }

    func isShooting(_ isShooting: Bool) {
        self.isShooting = isShooting
    }
}

