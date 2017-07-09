//
//  Updatable.swift
//  Time Fighter
//
//  Created by Wilson Martins on 05/07/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import Foundation
import SpriteKit

protocol Update {
    func update(_ currentTime: TimeInterval)
}

class Updatable: NSObject {

    private var updatableNodes: [Update] = [Update]()

    func addToUpdate(node: Update) {
        self.updatableNodes.append(node)
    }

    func updateNodes(_ currentTime: TimeInterval) {
        for nodes in updatableNodes {
            nodes.update(currentTime)
        }
    }
}
