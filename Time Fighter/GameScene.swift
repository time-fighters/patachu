//
//  GameScene.swift
//  Time Fighter
//
//  Created by Wilson Martins on 26/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: ControllableScene {

    private var movementJoystick: Joystick?
    private var shootingJoystick: Joystick?

    private let MAIN_SCREEN_BOUNDS = UIScreen.main.bounds
    private let JOYSTICK_WIDTH_POSITION: CGFloat = 0.6
    private let JOYSTICK_HEIGHT_POSITION: CGFloat = -0.4

    private var mainCharacter: SKNode = MainCharacter()
    private var shootingController: SKNode = MainCharacter()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Main Character
        self.mainCharacter = self.childNode(withName: "mainCharacter")!

        // Movement JoyStick
        self.movementJoystick = Joystick(movableObject: mainCharacter as! JoystickDirection)
        self.movementJoystick?.position = CGPoint(x: -self.MAIN_SCREEN_BOUNDS.width * self.JOYSTICK_WIDTH_POSITION, y: self.MAIN_SCREEN_BOUNDS.height * self.JOYSTICK_HEIGHT_POSITION)
        self.addChild(self.movementJoystick!)

        // Shooting JoyStick
        self.shootingJoystick = Joystick(movableObject: shootingController as! JoystickDirection)
        self.shootingJoystick?.position = CGPoint(x: self.MAIN_SCREEN_BOUNDS.width * self.JOYSTICK_WIDTH_POSITION, y: self.MAIN_SCREEN_BOUNDS.height * self.JOYSTICK_HEIGHT_POSITION)
        self.addChild(self.shootingJoystick!)
    }

    override func sceneDidLoad() {

    }
    
    override func didMove(to view: SKView) {
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

    override func controllerFor(touch: UITouch) -> UIResponder? {
        let touchPoint: CGPoint = touch.location(in: self)

        if (touchPoint.x < 0) {
            return self.movementJoystick
        } else {
            return self.shootingJoystick
        }
    }
}
