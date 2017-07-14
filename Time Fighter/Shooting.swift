//
//  Bullet.swift
//  Time Fighter
//
//  Created by Wilson Martins on 29/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
import SpriteKit

protocol Shoot {
    func shoot()
}

class Shooting: SKNode, JoystickController, Update, NodeInformation {

    var node: SKNode
    var bullet: SKNode
    var isShooting: Bool = false
    var direction: CGVector
    var angle: Double
    let parentRelativePosition: CGPoint
    let rateOfFire: Double = 0.3
    var lastShot: TimeInterval
    var parentScene: SKScene

    var bullets: Double = 6 {
        didSet {
//            let bulletCounter:SKLabelNode = (self.parentScene.childNode(withName: "bulletsCounter") as? SKLabelNode)!
//            bulletCounter.text = String(bullets)
        }
    }
    var isReloading: Bool = false

    var directionNode: NodeInformation

    let TIME_INTERVAL:Double = 1
    let BULLET_VELOCITY: Double = 600

    init(_ node: SKNode, _ bullet: SKNode, _ parentRelativePosition: CGPoint, _ directionNode: NodeInformation, _ scene: SKScene) {
        self.node = node
        self.parentRelativePosition = parentRelativePosition
        self.directionNode = directionNode

        self.bullet = bullet
        self.direction = CGVector()
        self.lastShot = TimeInterval()
        self.angle = 0

        self.parentScene = scene

        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func joystickInteraction(velocity: CGVector, angularVelocity: CGFloat) {
        self.direction = velocity
        self.angle = Double(angularVelocity)
    }

    func update(_ currentTime: TimeInterval) {
//       self.isShooting(isShooting)
        let vx: Double = self.BULLET_VELOCITY * cos(self.angle)
        let vy: Double = self.BULLET_VELOCITY * sin(self.angle)

        if (self.isShooting && vx < 0) {
            self.setDirection(.left)
            self.node.zRotation = .pi - CGFloat(self.angle)
        } else if (self.isShooting && vx >= 0) {
            self.setDirection(.right)
            self.node.zRotation = CGFloat(self.angle)
        } else if (!self.isShooting) {
            self.node.zRotation = 0
        }

        guard self.isShooting else {
            return
        }

        guard self.bullets > 0 else {
            if (!isReloading) {
                self.isShooting = false
                self.reload()
            }
            return
        }

        guard  currentTime - self.lastShot > self.rateOfFire else {
            return
        }

        self.lastShot = currentTime

        let bullet = self.makeBullet()
        bullet.physicsBody?.velocity = CGVector(dx: vx, dy: vy)
        bullet.physicsBody?.linearDamping = 0
        bullet.physicsBody?.affectedByGravity = false
        bullet.zRotation = CGFloat(self.angle)

        self.bullets -= 1
    }

    func configureStateMachine(forStatus status: JoystickStatusEnum) {
        if (status == .started) {
            self.isShooting(true, status: status)
        } else if (status == .running) {
            self.isShooting(true, status: status)
        }else if (status == .finished) {
            self.isShooting(false, status: status)
        }
    }


    func makeBullet() -> SKNode {
        let bullet = self.bullet.copy() as! SKSpriteNode
        bullet.zPosition = 0
        bullet.removeAllChildren()
        bullet.position = self.node.convert(CGPoint(x: self.node.position.x + 100, y: self.node.position.y - 10), to: self.bullet)
        bullet.zPosition = 0
        self.bullet.addChild(bullet)
        return bullet
    }

    func setDirection(_ direction: DirectionEnum) {
        self.directionNode.setDirection(direction)
    }

    func isShooting(_ isShooting: Bool, status: JoystickStatusEnum) {
        self.isShooting = isShooting
        self.directionNode.isShooting(isShooting, status: status)
    }

    func reload() {
        self.isReloading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.bullets = 6
            self.isReloading = false
        }
    }
}
