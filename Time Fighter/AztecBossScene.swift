//
//  AztecBossScene.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/13/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class AztecBossScene: ControllableScene, SKPhysicsContactDelegate {
    
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
    
    
    var pauseButton: SKSpriteNode?
    var MusicOnButton: SKSpriteNode?
    var MusicOffButton: SKSpriteNode?
    var quitButton: SKSpriteNode?
    var resumeButton: SKSpriteNode?
    var configButton: SKSpriteNode?
    let buttonsZPositionOn:CGFloat = -1
    let buttonsZPositionOff:CGFloat = -10
    
    var fireOn = [SKSpriteNode]()
    var lamp1:Torch?
    var lamp2:Torch?
    var lamp3:Torch?
    var lamp4:Torch?
    var boss:Boss?
    var light1: SKLightNode?
    var light2: SKLightNode?
    var light3: SKLightNode?
    var light4: SKLightNode?
    
    
    private var movableNodes: SKNode?
    
    var enemiesParent: SKNode?
    var originalEnemy: SKNode?
    var enemiesPosition: [CGPoint] = EnemyPosition.aztec
    
    var bgMusicPlayer: AVAudioPlayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func sceneDidLoad() {
        // Update nodes
        self.updatable = Updatable()
    }
    
    
    
    override func didMove(to view: SKView) {

        self.physicsWorld.contactDelegate = self
        
        self.lamp1 = self.childNode(withName: "Lamp1")  as? Torch
        self.lamp1?.lightingBitMask = 1
        self.lamp2 = self.childNode(withName: "Lamp2")  as? Torch
        self.lamp2?.lightingBitMask = 1
        self.lamp3 = self.childNode(withName: "Lamp3")  as? Torch
        self.lamp3?.lightingBitMask = 1
        self.lamp4 = self.childNode(withName: "Lamp4")  as? Torch
        self.lamp4?.lightingBitMask = 1
        
        
        self.lamp1?.animate(scene: self)
        self.lamp2?.animate(scene: self)
        self.lamp3?.animate(scene: self)
        self.lamp4?.animate(scene: self)
        
        self.light1 = self.childNode(withName: "Light1") as! SKLightNode
        self.light2 = self.childNode(withName: "Light2") as! SKLightNode
        self.light3 = self.childNode(withName: "Light3") as! SKLightNode
        self.light4 = self.childNode(withName: "Light4") as! SKLightNode
        
        
        self.boss = self.childNode(withName: "AztecBoss") as? Boss
        self.boss?.animate(scene: self)
        
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
        
        //Botoes da settings and config
        pauseButton = self.mainCamera?.childNode(withName: "PauseButton") as? SKSpriteNode
        pauseButton?.zPosition = buttonsZPositionOn
        
        resumeButton = self.mainCamera?.childNode(withName: "ResumeButton") as? SKSpriteNode
        resumeButton?.zPosition = buttonsZPositionOff
        
        MusicOnButton = self.mainCamera?.childNode(withName: "MusicOnButton") as? SKSpriteNode
        MusicOnButton?.zPosition  = buttonsZPositionOff
        MusicOffButton = self.mainCamera?.childNode(withName: "MusicOffButton") as? SKSpriteNode
        MusicOffButton?.zPosition = buttonsZPositionOff
        
        quitButton = self.mainCamera?.childNode(withName: "QuitButton") as? SKSpriteNode
        quitButton?.zPosition = buttonsZPositionOff
        
        configButton = self.mainCamera?.childNode(withName: "ConfigButton") as? SKSpriteNode
        configButton?.zPosition = buttonsZPositionOff
        
        for bg in (background?.children)! {
            bg.physicsBody?.categoryBitMask = GameElements.ground
            bg.physicsBody?.collisionBitMask = GameElements.mainCharacter | GameElements.enemy
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
        self.mainCharacter?.physicsBody?.collisionBitMask = GameElements.ground | GameElements.boundaries | GameElements.camera | GameElements.enemy
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
        
        self.playBackgroundMusic()
        
    }
        override func update(_ currentTime: TimeInterval) {
            super.update(currentTime)
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

            self.lastCameraPosition = self.mainCameraBoundary?.position
            
            let rightBoundary = self.mainCamera?.childNode(withName: "boundaries")?.childNode(withName: "right")
            //
            //        guard self.enemiesPosition.count > 0 else {
            //            return
            //        }
            //
            //        if (Float((self.enemiesPosition.first?.x)!) <= Float((rightBoundary?.parent?.convert((rightBoundary?.position)!, to: self).x)!)) {
            //            self.createEnemy(position: self.enemiesPosition.removeFirst())
            //        }
        }
        
        func createEnemy(position: CGPoint) {
            let newEnemy: SKNode = self.originalEnemy?.copy() as! SKNode
            newEnemy.physicsBody?.affectedByGravity = true
            newEnemy.position = position
            self.enemiesParent?.addChild(newEnemy)
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
            
            // Bullets and Enemies
            if (contact.bodyA.categoryBitMask == GameElements.bullet && contact.bodyB.categoryBitMask == GameElements.enemy) {
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
            }
            if (contact.bodyA.categoryBitMask == GameElements.enemy && contact.bodyB.categoryBitMask == GameElements.bullet) {
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
            }
            
        }
    
        func playBackgroundMusic()
        {
            if self.bgMusicPlayer == nil {
                
                let musicPath = Bundle.main.path(forResource: "aztec", ofType: "mp3")
                let musicUrl = URL(fileURLWithPath: musicPath!)
                
                self.bgMusicPlayer = try! AVAudioPlayer(contentsOf: musicUrl)
                
                self.bgMusicPlayer.numberOfLoops = -1 // tocar para sempre
                
                self.bgMusicPlayer.prepareToPlay()
            }
            
            self.bgMusicPlayer.pause()
            self.bgMusicPlayer.currentTime = 0
            self.bgMusicPlayer.play()
        }


        
    }
