//
//  MainCharacter.swift
//  Time Fighter
//
//  Created by Wilson Martins on 28/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import Foundation
import SpriteKit

enum CharacterMovementEnum: String {
    case walk
    case jump
    case idle
}

class MainCharacter: SKSpriteNode, JoystickController, Animate, Update {

    let VELOCITY: CGFloat = 7
    var xVelocity: Double = 0
    var yVelocity: Double = 0
    var body: BodyCharacter!
    var arm: ArmCharacter!
    let stateMachine:StateMachine = StateMachine()
    var status: CharacterMovementEnum = .idle
    
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
        if (status == .started) {
            self.status = .walk
        } else if (status == .finished) {
            self.status = .idle
        }
    }

    func animate(scene: SKScene, state: UInt32 ) {}

    func update(_ currentTime: TimeInterval) {
        if (self.status == .walk) {
            self.run(SKAction.move(by: CGVector(dx: self.xVelocity, dy: 0), duration: 1))
        }

        self.arm.position = CGPoint(x: self.body.position.x + 19, y: self.body.position.y)
    }
}

