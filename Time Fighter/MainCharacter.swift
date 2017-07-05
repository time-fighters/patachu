//
//  MainCharacter.swift
//  Time Fighter
//
//  Created by Wilson Martins on 28/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import Foundation
import SpriteKit

class MainCharacter: SKSpriteNode, JoystickDirection {

    let MAX_VELOCITY: CGFloat = 400.0
    let ACCELERATION: CGFloat = 3.0

    func joystickInteraction(velocity: CGVector, angularVelocity: CGFloat) {
        self.physicsBody?.velocity = CGVector(dx: ACCELERATION * copysign(CGFloat.minimumMagnitude(self.MAX_VELOCITY, abs(velocity.dx)), velocity.dx), dy: ACCELERATION * copysign(CGFloat.minimumMagnitude(self.MAX_VELOCITY, abs(velocity.dy)), velocity.dy))
    }
}
