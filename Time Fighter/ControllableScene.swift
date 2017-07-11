//
//  ControllableScene.swift
//  Time Fighter
//
//  Created by Wilson Martins on 29/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol Controllable {
    func controllerFor(touch:UITouch) -> UIResponder?
}

class ControllableScene: SKScene, Controllable {

    func controllerFor(touch: UITouch) -> UIResponder? {
        return nil
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let controller = controllerFor(touch: touch) {
                controller.touchesBegan(touches, with: event)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let controller = controllerFor(touch: touch) {
                controller.touchesMoved(touches, with: event)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let controller = controllerFor(touch: touch) {
                controller.touchesEnded(touches, with: event)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let controller = controllerFor(touch: touch) {
                controller.touchesCancelled(touches, with: event)
            }
        }
    }
}
