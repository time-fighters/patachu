//
//  GameScene.swift
//  Time Fighter
//
//  Created by Wilson Martins on 26/06/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

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
    
    var pauseButton: SKSpriteNode?
    var MusicOnButton: SKSpriteNode?
    var MusicOffButton: SKSpriteNode?
    var quitButton: SKSpriteNode?
    var resumeButton: SKSpriteNode?
    var configButton: SKSpriteNode?
    
    private var movableNodes: SKNode?

    var sky = BackgroundParallax(spriteName: "Sky")
    var moutains = BackgroundParallax(spriteName: "Mountains")
    var city = BackgroundParallax(spriteName: "City")
    var door:SKSpriteNode?

    let zpostionSky:CGFloat = -5
    let zPositionMountains: CGFloat = -4
    let zPositionCity: CGFloat = -3
    let skySize:CGSize = CGSize(width: 1500, height: 750)
    let mountainsSize:CGSize = CGSize(width: 1500, height: 750)
    let citySize:CGSize = CGSize(width: 2554, height: 750)
    let buttonsZPositionOn:CGFloat = -1
    let buttonsZPositionOff:CGFloat = -10

    var enemiesParent: AztecEnemy?
    var originalEnemy: AztecEnemy?
    var enemiesPosition: [CGPoint] = EnemyPosition.aztec
    var stairsPath:SKShapeNode?
    var bgMusicPlayer: AVAudioPlayer!

    var sceneLimit: SKNode?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func sceneDidLoad() {
        // Update nodes
        self.updatable = Updatable()
    }

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        Ground(scene: self)

        cameraSetup()
        buttonsSetup()
        sceneBackgroundSetup()
        bulletSetup()

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
        shootController = Shooting(mainCharacterArm!, bulletSetup(), CGPoint(x: 0, y: 0), self.mainCharacter!, self)
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

        // Enemies
        self.enemiesParent = self.childNode(withName: "enemies") as? AztecEnemy
        self.originalEnemy = self.enemiesParent?.childNode(withName: "enemy") as? AztecEnemy

        self.originalEnemy?.physicsBody?.categoryBitMask = GameElements.enemy
        self.originalEnemy?.physicsBody?.collisionBitMask = GameElements.ground | GameElements.mainCharacter
        self.originalEnemy?.physicsBody?.contactTestBitMask = GameElements.mainCharacter | GameElements.bullet

        self.run(SKAction.playSoundFileNamed("BossLaugh.mp3", waitForCompletion: false))
        self.playBackgroundMusic()

        self.sceneLimit = self.childNode(withName: "sceneLimit")
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

        // Move Camera
        let positionDifferencial = max((self.mainCameraBoundary?.position.x)! - (self.lastCameraPosition?.x)!, 0)

        self.moveCamera(by: positionDifferencial)

        // Next, move each of the four pairs of sprites.
        // Objects that should appear move slower than foreground objects.
        self.sky.moveSprite(withSpeed: -50 * Float(positionDifferencial), deltaTime: deltaTime, scene: self)
        self.moutains.moveSprite(withSpeed: -30 * Float(positionDifferencial), deltaTime: deltaTime, scene: self)
        self.city.moveSprite(withSpeed: -1 * Float(positionDifferencial), deltaTime: deltaTime, scene: self)

        self.lastCameraPosition = self.mainCameraBoundary?.position

        // Spawn enemies
        let rightBoundary = self.mainCamera?.childNode(withName: "boundaries")?.childNode(withName: "right")
        guard self.enemiesPosition.count > 0 else {
            return
        }

        if (Float((self.enemiesPosition.first?.x)!) <= Float((rightBoundary?.parent?.convert((rightBoundary?.position)!, to: self).x)!)) {
            self.createEnemy(position: self.enemiesPosition.removeFirst())
            
        }
    }

    func moveCamera(by positionDifferencial: CGFloat) {
        guard (self.mainCamera?.position.x)! + self.size.width/2 < (self.sceneLimit?.position.x)! else {
            return
        }
        self.mainCamera?.position = CGPoint(x: (self.mainCameraBoundary?.position.x)! + positionDifferencial, y: (self.mainCamera?.position.y)!)
    }

    // Create a new enemy node
    func createEnemy(position: CGPoint) {
        let newEnemy: AztecEnemy = self.originalEnemy?.copy() as! AztecEnemy
        newEnemy.physicsBody?.affectedByGravity = true
        newEnemy.position = self.convert(position, to: newEnemy)
        newEnemy.animateIdle(scene: self)
        newEnemy.physicsBody?.restitution = 0
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
            self.run(SKAction.playSoundFileNamed("JumpEnding", waitForCompletion: false))
            
        }
        if (contact.bodyA.categoryBitMask == GameElements.ground && contact.bodyB.categoryBitMask == GameElements.mainCharacter) {
            let mainCharacter = contact.bodyB.node as! MainCharacter
            mainCharacter.isJumping = false
           self.run(SKAction.playSoundFileNamed("JumpEnding", waitForCompletion: false))
        }

        // Bullets and Enemies
        if (contact.bodyA.categoryBitMask == GameElements.bullet && contact.bodyB.categoryBitMask == GameElements.enemy) {
            self.run(SKAction.playSoundFileNamed("EnemyDeath", waitForCompletion: false))
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
        if (contact.bodyA.categoryBitMask == GameElements.enemy && contact.bodyB.categoryBitMask == GameElements.bullet) {
            self.run(SKAction.playSoundFileNamed("EnemyDeath", waitForCompletion: false))
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
        
        //Main Character and Door
        if (contact.bodyA.categoryBitMask == GameElements.mainCharacter && contact.bodyB.categoryBitMask == GameElements.bossDoor) {
            if let scene = SKScene(fileNamed: "AztecBossScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view!.presentScene(scene)
            }
            
        }
        if (contact.bodyA.categoryBitMask == GameElements.bossDoor && contact.bodyB.categoryBitMask == GameElements.mainCharacter) {
            if let scene = SKScene(fileNamed: "AztecBossScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view!.presentScene(scene)
            }
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
    
    func cameraSetup(){
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

    }
    
    func buttonsSetup(){
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
    }
    
    func sceneBackgroundSetup()
    {
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
            bg.physicsBody?.collisionBitMask = GameElements.mainCharacter | GameElements.enemy
            bg.physicsBody?.contactTestBitMask = GameElements.bullet | GameElements.mainCharacter
        }
        
        //Door
        door = self.childNode(withName: "TempleDoor") as? SKSpriteNode
        door?.physicsBody?.categoryBitMask = GameElements.bossDoor
        door?.physicsBody?.collisionBitMask = GameElements.mainCharacter
        door?.physicsBody?.contactTestBitMask = GameElements.mainCharacter
    }
    func bulletSetup() -> SKNode{
        // Bullet
        let bullet = self.childNode(withName: "bullet")
        bullet?.physicsBody?.categoryBitMask = GameElements.bullet
        bullet?.physicsBody?.collisionBitMask = GameElements.enemy | GameElements.ground
        bullet?.physicsBody?.contactTestBitMask = GameElements.boundaries | GameElements.enemy | GameElements.ground
        
        return bullet!
    }
   
}
