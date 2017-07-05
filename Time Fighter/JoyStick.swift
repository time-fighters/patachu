//
//  MainCharacter.swift
//  Time Fighter
//
//  Created by Wilson Martins on 28/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import Foundation
import SpriteKit

protocol JoystickDirection {
    func joystickInteraction(velocity: CGVector, angularVelocity: CGFloat)
}

class Joystick : SKNode {
    let kThumbSpringBackDuration: Double =  0.3
    let backdropNode, thumbNode: SKSpriteNode
    var isTracking: Bool = true
    var velocity: CGVector = CGVector(dx: 0, dy: 0)
    var travelLimit: CGPoint = CGPoint(x: 0, y: 0)
    var angularVelocity: CGFloat = 0.0
    var size: Float = 0.0
    var movableNode: MainCharacter

    func anchorPointInPoints() -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }

    init(movableObject movableNode: JoystickDirection, thumbNode: SKSpriteNode = SKSpriteNode(imageNamed: "JoyStickHandle"), backdropNode: SKSpriteNode = SKSpriteNode(imageNamed: "JoyStickBase")) {
        self.thumbNode = thumbNode
        self.backdropNode = backdropNode
        self.movableNode = movableNode as! MainCharacter

        super.init()

        self.addChild(self.backdropNode)
        self.addChild(self.thumbNode)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /// Movement functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let parentTouchPoint: CGPoint = touch.location(in: self.parent!)
            self.position = parentTouchPoint
            self.isTracking = true
            print("Touches began!")
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.location(in: self)

            let moveDifference: CGPoint = CGPoint(x: touchPoint.x - self.anchorPointInPoints().x, y: touchPoint.y - self.anchorPointInPoints().y)
            self.thumbNode.position = CGPoint(x: self.anchorPointInPoints().x + moveDifference.x, y: self.anchorPointInPoints().y + moveDifference.y)

            let xVelocity = self.thumbNode.position.x - self.anchorPointInPoints().x
            let yVelocity = self.thumbNode.position.y - self.anchorPointInPoints().y

            self.velocity = CGVector(dx: xVelocity, dy: yVelocity)

            self.angularVelocity = -atan2(self.thumbNode.position.x - self.anchorPointInPoints().x, self.thumbNode.position.y - self.anchorPointInPoints().y)
            print("Touches moved!")
            print(velocity)
            self.movableNode.joystickInteraction(velocity: velocity, angularVelocity: angularVelocity)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches ended!")
        self.resetVelocity()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches cancelled!")
        self.resetVelocity()
    }

    func resetVelocity() {
        self.isTracking = false
        self.velocity = CGVector.zero
        let easeOut: SKAction = SKAction.move(to: self.anchorPointInPoints(), duration: kThumbSpringBackDuration)
        easeOut.timingMode = SKActionTimingMode.easeOut
        self.thumbNode.run(easeOut)
    }
}
