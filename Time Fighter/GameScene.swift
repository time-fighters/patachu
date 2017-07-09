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
    
    // Time of last frame
    var lastFrameTime : TimeInterval = 0
    // Time since last frame
    var deltaTime : TimeInterval = 0

    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private let MAIN_SCREEN_BOUNDS = UIScreen.main.bounds
    private let JOYSTICK_WIDTH_POSITION: CGFloat = 0.6
    private let JOYSTICK_HEIGHT_POSITION: CGFloat = -0.4

    private var mainCharacter: MainCharacter?
    private var shootController: Shooting?
    private var updatable: Updatable?

    var sky = BackgroundParallax(spriteName: "Sky")
    var moutains = BackgroundParallax(spriteName: "Mountains")
    var city = BackgroundParallax(spriteName: "City")

    let zpostionSky:CGFloat = -5
    let zPositionMountains: CGFloat = -4
    let zPositionCity: CGFloat = -3
    let skySize:CGSize = CGSize(width: 1500, height: 750)
    let mountainsSize:CGSize = CGSize(width: 1500, height: 750)
    let citySize:CGSize = CGSize(width: 2554, height: 750)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func sceneDidLoad() {
        // Update nodes
        self.updatable = Updatable()
    }

    override func didMove(to view: SKView) {
        
        // Main Character
        self.mainCharacter = self.childNode(withName: "mainCharacter")! as? MainCharacter
        let mainCharacterArm = mainCharacter?.childNode(withName: "arm")
        let bullet = mainCharacterArm?.childNode(withName: "bullet")
        self.mainCharacter?.state = StateMachine.idle
        self.updatable?.addToUpdate(node: self.mainCharacter!)

        shootController = Shooting(shootingNode: mainCharacterArm!, bullet: bullet!, parentRelativePosition: CGPoint(x: 0, y: 0))
        self.updatable?.addToUpdate(node: self.shootController!)


//        let texture = mainCharacter?.texture
//        var animationTextures = [SKTexture]()
//
//        //Break texture into frames
//        for pos in stride(from: 0.0, to: 1.0, by: 0.5) {
//            let cutter = CGRect(x: pos, y: 0, width: 0.5, height: 1.0)
//            let frame = SKTexture(rect: cutter, in: texture!)
//            animationTextures.append(frame)
//        }

//        mainCharacter?.texture = animationTextures[0]
        // Create frame animation
//        let animateTexture = SKAction.repeatForever(SKAction.animate(with: animationTextures, timePerFrame: 0.19))

        //Run, Forrest, run!
//        mainCharacter?.run(animateTexture)

        
        // Movement JoyStick
        self.movementJoystick = Joystick(movableObject: mainCharacter!)
        self.movementJoystick?.position = CGPoint(x: -self.MAIN_SCREEN_BOUNDS.width * self.JOYSTICK_WIDTH_POSITION, y: self.MAIN_SCREEN_BOUNDS.height * self.JOYSTICK_HEIGHT_POSITION)
        self.addChild(self.movementJoystick!)

        /// Shooting JoyStick
        self.shootingJoystick = Joystick(movableObject: shootController!)
        self.shootingJoystick?.position = CGPoint(x: self.MAIN_SCREEN_BOUNDS.width * self.JOYSTICK_WIDTH_POSITION, y: self.MAIN_SCREEN_BOUNDS.height * self.JOYSTICK_HEIGHT_POSITION)
        self.addChild(self.shootingJoystick!)
        
        let leftCornerPosition:CGPoint = CGPoint(x: -self.size.width/2, y: -self.size.height/2)
        
        sky.createBackgroundNode(zpostion: zpostionSky, anchorPoint: CGPoint.zero, screenPosition: leftCornerPosition, spriteSize: skySize, scene: self)
        moutains.createBackgroundNode(zpostion: zPositionMountains, anchorPoint: CGPoint.zero, screenPosition: leftCornerPosition, spriteSize: mountainsSize, scene: self)
        city.createBackgroundNode(zpostion: zPositionCity, anchorPoint: CGPoint.zero, screenPosition: leftCornerPosition, spriteSize: citySize, scene: self)

    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        self.updatable?.updateNodes(currentTime)

        // First, update the delta time values:
        // If we don't have a last frame time value, this is the first frame,
        // so delta time will be zero.
        if lastFrameTime <= 0 {
            lastFrameTime = currentTime
        }
        
        // Update delta time
        deltaTime = currentTime - lastFrameTime
        
        // Set last frame time to current time
        lastFrameTime = currentTime
        
        // Next, move each of the four pairs of sprites.
        // Objects that should appear move slower than foreground objects.
        sky.moveSprite(withSpeed: 25, deltaTime: deltaTime, scene: self)
        moutains.moveSprite(withSpeed: 55, deltaTime: deltaTime, scene: self)
        city.moveSprite(withSpeed: 150, deltaTime: deltaTime, scene: self)

    }

    
    /// Identifies the side of screen touched by the user and choose what joystick use
    ///
    /// - Parameter touch: touch type
    /// - Returns: return the correct joystick
    override func controllerFor(touch: UITouch) -> UIResponder? {
        let touchPoint: CGPoint = touch.location(in: self)
        if (touchPoint.x < 0) {
            return self.movementJoystick
        } else {
            return self.shootingJoystick
        }
    }

}
