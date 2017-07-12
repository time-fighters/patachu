//
//  GameScene.swift
//  Time Fighter
//
//  Created by Wilson Martins on 26/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: ControllableScene, SKPhysicsContactDelegate {

    private var movementJoystick: Joystick?
    private var shootingJoystick: Joystick?
    
    // Time of last frame
    var lastFrameTime : TimeInterval = 0
    // Time since last frame
    var deltaTime : TimeInterval = 0


    private var mainCamera: SKCameraNode?
    private var mainCameraBoundary: SKNode?
    private var lastCameraPosition: CGPoint?
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private let MAIN_SCREEN_BOUNDS = UIScreen.main.bounds
    private let JOYSTICK_WIDTH_POSITION: CGFloat = 0.6
    private let JOYSTICK_HEIGHT_POSITION: CGFloat = -0.4

    private var mainCharacter: MainCharacter?
    private var shootController: Shooting?
    private var updatable: Updatable?

    private var movableNodes: SKNode?

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
        self.physicsWorld.contactDelegate = self

        // Camera
        self.mainCamera = self.childNode(withName: "mainCamera") as? SKCameraNode
        self.mainCamera?.physicsBody?.categoryBitMask = 0
        self.mainCamera?.physicsBody?.collisionBitMask = 0
        self.mainCamera?.physicsBody?.contactTestBitMask = 0

        // Camera Boundary
        self.mainCameraBoundary = self.childNode(withName: "cameraBoundary")
        self.mainCameraBoundary?.physicsBody?.categoryBitMask = GameElements.camera
        self.mainCameraBoundary?.physicsBody?.collisionBitMask = GameElements.mainCharacter
        self.mainCameraBoundary?.physicsBody?.contactTestBitMask = 0

        // Movable Nodes
        self.movableNodes = self.childNode(withName: "movable")

        // Boundaries
        let boundaries = self.mainCamera?.childNode(withName: "boundaries")

        for boundary in (boundaries?.children)! {
            boundary.physicsBody?.categoryBitMask = GameElements.boundaries
            boundary.physicsBody?.collisionBitMask = GameElements.mainCharacter
            boundary.physicsBody?.contactTestBitMask = GameElements.bullet
        }

        // Ground
        let background = self.movableNodes?.childNode(withName: "background")

        for bg in (background?.children)! {
            bg.physicsBody?.categoryBitMask = GameElements.ground
            bg.physicsBody?.collisionBitMask = GameElements.mainCharacter
            bg.physicsBody?.contactTestBitMask = GameElements.bullet | GameElements.mainCharacter
        }

        // Bullet
        let bullet = self.childNode(withName: "bullet")
        bullet?.physicsBody?.categoryBitMask = GameElements.bullet
        bullet?.physicsBody?.collisionBitMask = GameElements.enemy | GameElements.ground
        bullet?.physicsBody?.contactTestBitMask = GameElements.boundaries | GameElements.enemy | GameElements.ground
        
        // Main Character
        self.mainCharacter = self.childNode(withName: "mainCharacter")! as? MainCharacter
        let mainCharacterArm = mainCharacter?.childNode(withName: "arm")
        self.mainCharacter?.state = StateMachine.idle
        self.updatable?.addToUpdate(node: self.mainCharacter!)
        self.lastCameraPosition = self.mainCharacter?.position

        self.mainCharacter?.physicsBody?.categoryBitMask = GameElements.mainCharacter
        self.mainCharacter?.physicsBody?.collisionBitMask = GameElements.ground | GameElements.boundaries | GameElements.camera
        self.mainCharacter?.physicsBody?.contactTestBitMask = GameElements.enemy | GameElements.ground

        // Movement JoyStick
        self.movementJoystick = Joystick(movableObject: mainCharacter!)
        self.movementJoystick?.position = CGPoint(x: -self.MAIN_SCREEN_BOUNDS.width * self.JOYSTICK_WIDTH_POSITION, y: self.MAIN_SCREEN_BOUNDS.height * self.JOYSTICK_HEIGHT_POSITION)
        self.addChild(self.movementJoystick!)

        /** Shooting */
        // Shooting Controller
        shootController = Shooting(mainCharacterArm!, bullet!, CGPoint(x: 0, y: 0), self.mainCharacter!)
        self.updatable?.addToUpdate(node: self.shootController!)


        /// Shooting JoyStick
        self.shootingJoystick = Joystick(movableObject: shootController!)
        self.shootingJoystick?.position = CGPoint(x: self.MAIN_SCREEN_BOUNDS.width * self.JOYSTICK_WIDTH_POSITION, y: self.MAIN_SCREEN_BOUNDS.height * self.JOYSTICK_HEIGHT_POSITION)
        self.addChild(self.shootingJoystick!)

        // Background
        let leftCornerPosition:CGPoint = CGPoint(x: -self.size.width/2, y: -self.size.height/2)
        
        self.sky.createBackgroundNode(zpostion: zpostionSky, anchorPoint: CGPoint.zero, screenPosition: leftCornerPosition, spriteSize: skySize, scene: self)
        self.moutains.createBackgroundNode(zpostion: zPositionMountains, anchorPoint: CGPoint.zero, screenPosition: leftCornerPosition, spriteSize: mountainsSize, scene: self)
        self.city.createBackgroundNode(zpostion: zPositionCity, anchorPoint: CGPoint.zero, screenPosition: leftCornerPosition, spriteSize: citySize, scene: self)
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

        let positionDifferencial = max((self.mainCameraBoundary?.position.x)! - (self.lastCameraPosition?.x)!, 0)
        
        self.mainCamera?.position = CGPoint(x: (self.mainCameraBoundary?.position.x)! + positionDifferencial, y: (self.mainCamera?.position.y)!)

        print(Float(positionDifferencial))

        // Next, move each of the four pairs of sprites.
        // Objects that should appear move slower than foreground objects.
        self.sky.moveSprite(withSpeed: 5 * Float(positionDifferencial), deltaTime: deltaTime, scene: self)
        self.moutains.moveSprite(withSpeed: 15 * Float(positionDifferencial), deltaTime: deltaTime, scene: self)
        self.city.moveSprite(withSpeed: 30 * Float(positionDifferencial), deltaTime: deltaTime, scene: self)

        self.lastCameraPosition = self.mainCameraBoundary?.position
    }


    /// Identifies the side of screen touched by the user and choose what joystick use
    ///
    /// - Parameter touch: touch type
    /// - Returns: return the correct joystick
    override func controllerFor(touch: UITouch) -> UIResponder? {
        let touchPoint: CGPoint = touch.location(in: self)
        if (touchPoint.x < (self.mainCamera?.position.x)!) {
            return self.movementJoystick
        } else {
            return self.shootingJoystick
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // Bullets and Boundaries
        if (contact.bodyA.categoryBitMask == GameElements.bullet && contact.bodyB.categoryBitMask == GameElements.boundaries) {
            contact.bodyA.node?.removeFromParent()
        }
        if (contact.bodyA.categoryBitMask == GameElements.boundaries && contact.bodyB.categoryBitMask == GameElements.bullet) {
            contact.bodyB.node?.removeFromParent()
        }

        // Bullets and Ground
        if (contact.bodyA.categoryBitMask == GameElements.bullet && contact.bodyB.categoryBitMask == GameElements.ground) {
            contact.bodyA.node?.removeFromParent()
        }
        if (contact.bodyA.categoryBitMask == GameElements.ground && contact.bodyB.categoryBitMask == GameElements.bullet) {
            contact.bodyB.node?.removeFromParent()
        }

        // Main Character and Ground
        if (contact.bodyA.categoryBitMask == GameElements.mainCharacter && contact.bodyB.categoryBitMask == GameElements.ground) {
            let mainCharacter = contact.bodyA.node as! MainCharacter
            mainCharacter.isJumping = false
        }
        if (contact.bodyA.categoryBitMask == GameElements.ground && contact.bodyB.categoryBitMask == GameElements.mainCharacter) {
            let mainCharacter = contact.bodyB.node as! MainCharacter
            mainCharacter.isJumping = false
        }
    }
}
