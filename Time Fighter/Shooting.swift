//
//  Bullet.swift
//  Time Fighter
//
//  Created by Wilson Martins on 29/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import Foundation
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

    var directionNode: NodeInformation

    let TIME_INTERVAL:Double = 1
    let BULLET_VELOCITY: Double = 600

    init(_ node: SKNode, _ bullet: SKNode, _ parentRelativePosition: CGPoint, _ directionNode: NodeInformation) {
        self.node = node
        self.parentRelativePosition = parentRelativePosition
        self.directionNode = directionNode

        self.bullet = bullet
        self.direction = CGVector()
        self.lastShot = TimeInterval()
        self.angle = 0

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
        guard self.isShooting else {
            return
        }

        guard  currentTime - self.lastShot > self.rateOfFire else {
            return
        }

        self.lastShot = currentTime

        let bullet = self.makeBullet()
        let vx: Double = self.BULLET_VELOCITY * cos(self.angle)
        let vy: Double = self.BULLET_VELOCITY * sin(self.angle)
        bullet.physicsBody?.velocity = CGVector(dx: vx, dy: vy)
        bullet.physicsBody?.linearDamping = 0
        bullet.physicsBody?.affectedByGravity = false
        bullet.zRotation = CGFloat(self.angle)

        if (self.isShooting && vx < 0) {
            self.setDirection(.left)
        } else if (self.isShooting && vx >= 0) {
            self.setDirection(.right)
        }

    }

    func status(status: JoystickStatusEnum) {
        if (status == .started) {
            self.isShooting(true)
        } else if (status == .finished) {
            self.isShooting(false)
        }
    }

    func makeBullet() -> SKNode {
        let bullet = self.bullet.copy() as! SKSpriteNode
        bullet.zPosition = 0
        bullet.removeAllChildren()
        bullet.position = self.node.convert(CGPoint(x: self.node.position.x + 20, y: self.node.position.y - 10), to: self.bullet)
        bullet.zPosition = 0
        self.bullet.addChild(bullet)
        print(bullet.position)
        print(self.bullet.children.count)
        return bullet
    }

    func setDirection(_ direction: DirectionEnum) {
        self.directionNode.setDirection(direction)
    }

    func isShooting(_ isShooting: Bool) {
        self.isShooting = isShooting
        self.directionNode.isShooting(isShooting)
    }
}
