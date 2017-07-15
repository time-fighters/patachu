//
//  MainMenu.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/13/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class MainMenu: ControllableScene, SKPhysicsContactDelegate  {
    
    private var movementJoystick: Joystick?
    private var shootingJoystick: Joystick?
    
    // Time of last frame
    var lastFrameTime : TimeInterval = 0
    // Time since last frame
    var deltaTime : TimeInterval = 0
    
    
    private var mainCamera: SKCameraNode?
    private var mainCameraBoundary: SKNode?
    private var lastCameraPosition: CGPoint?
    
    private var mainCharacter: MainCharacter?
    private var shootController: Shooting?
    private var updatable: Updatable?
    
    
    var configOpen:Bool = false
    var soundsOn: Bool = true
    var configButton: SKSpriteNode?
    var soundsOnButton: SKSpriteNode?
    var soundsOffButton: SKSpriteNode?
    var logo: SKSpriteNode?
    var playButton: SKSpriteNode?
    var portal:SKSpriteNode?
    let buttonsZPositionOn:CGFloat = 5
    let buttonsZPositionOff:CGFloat = -10
    
    
    private var movableNodes: SKNode?
    
    private let MAIN_SCREEN_BOUNDS = UIScreen.main.bounds
    private let JOYSTICK_WIDTH_POSITION: CGFloat = 0.6
    private let JOYSTICK_HEIGHT_POSITION: CGFloat = -0.4
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func sceneDidLoad() {
        // Update nodes
        self.updatable = Updatable()
    }
    
    
    var bgMusicPlayer: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.playButton = self.childNode(withName: "playAztecWorld") as? SKSpriteNode
        self.playButton?.zPosition = buttonsZPositionOff
        
        self.portal = self.childNode(withName: "showPlayButton") as? SKSpriteNode
        self.portal?.physicsBody?.categoryBitMask = GameElements.portalAztec
        self.portal?.physicsBody?.collisionBitMask = 0
        self.portal?.physicsBody?.contactTestBitMask = GameElements.mainCharacter

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
        
        // Main Character
        self.mainCharacter = self.childNode(withName: "mainCharacter")! as? MainCharacter
        let mainCharacterArm = mainCharacter?.childNode(withName: "arm")
        self.mainCharacter?.state = StateMachine.idle
        self.updatable?.addToUpdate(node: self.mainCharacter!)
        self.lastCameraPosition = self.mainCharacter?.position
        
        self.playBackgroundMusic()
        self.mainCharacter?.physicsBody?.categoryBitMask = GameElements.mainCharacter
        self.mainCharacter?.physicsBody?.collisionBitMask = GameElements.ground | GameElements.boundaries | GameElements.camera | GameElements.enemy
        self.mainCharacter?.physicsBody?.contactTestBitMask = GameElements.enemy | GameElements.ground | GameElements.portalAztec
        
        
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
        
        // Bullet
        let bullet = self.childNode(withName: "bullet")
        bullet?.physicsBody?.categoryBitMask = GameElements.bullet
        bullet?.physicsBody?.collisionBitMask = GameElements.enemy | GameElements.ground
        bullet?.physicsBody?.contactTestBitMask = GameElements.boundaries | GameElements.enemy | GameElements.ground
        
        // Movement JoyStick
        self.movementJoystick = Joystick(movableObject: mainCharacter!)
        self.movementJoystick?.position = CGPoint(x: -self.MAIN_SCREEN_BOUNDS.width * self.JOYSTICK_WIDTH_POSITION, y: self.MAIN_SCREEN_BOUNDS.height * self.JOYSTICK_HEIGHT_POSITION)
        self.addChild(self.movementJoystick!)
        
        /** Shooting */
        // Shooting Controller
        shootController = Shooting(mainCharacterArm!, bullet!, CGPoint(x: 0, y: 0), self.mainCharacter!, self)
        self.updatable?.addToUpdate(node: self.shootController!)
        
        /// Shooting JoyStick
        self.shootingJoystick = Joystick(movableObject: shootController!)
        self.shootingJoystick?.position = CGPoint(x: self.MAIN_SCREEN_BOUNDS.width * self.JOYSTICK_WIDTH_POSITION, y: self.MAIN_SCREEN_BOUNDS.height * self.JOYSTICK_HEIGHT_POSITION)
        self.addChild(self.shootingJoystick!)
        
        self.logo = self.childNode(withName: "Logo") as? SKSpriteNode
        self.configButton = self.mainCamera?.childNode(withName: "Config") as? SKSpriteNode
        self.configButton?.zPosition = buttonsZPositionOn
        self.soundsOnButton = self.mainCamera?.childNode(withName: "SoundsOn") as? SKSpriteNode
        self.soundsOnButton?.zPosition  = buttonsZPositionOff
        self.soundsOffButton = self.mainCamera?.childNode(withName: "SoundsOff") as? SKSpriteNode
        self.soundsOffButton?.zPosition = buttonsZPositionOff
        
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
    }
    
    
    func createLevelSceneWithLevel(level: String) -> SKScene? {
        var levelScene: SKScene?
        switch level {
        case "playAztecWorld":
            levelScene = SKScene(fileNamed: "GameScene")
            print("Gamescene")
        case "MainMenu":
            print("Menu")
        default: levelScene = nil
        }
        
        levelScene?.scaleMode = .aspectFill
        
        return levelScene
    }
    
    func selectLevel(withName level: String) {
        let fadeTransition = SKTransition.fade(withDuration: 0.3)
        if let selectedLevel = createLevelSceneWithLevel(level: level) {
            self.view?.presentScene(selectedLevel, transition: fadeTransition)
        }
    }
    
    // Not a good idea if you progressively adding new levels,
    // it's totally depend on how you gonna organize your levels.
    // Since its level input is not arbitrary, the output of this
    // rarely nil, if it does, it must be the developer mistake.
    
    
    override func controllerFor(touch: UITouch) -> UIResponder? {
        let touchPoint: CGPoint = touch.location(in: self)
        if (touchPoint.x < (self.mainCamera?.position.x)!) {
            return self.movementJoystick
        } else {
            return self.shootingJoystick
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        let node =  self.atPoint(location)
        
        // If next button is touched, start transition to second scene
        if (node.name == "playAztecWorld") {
            self.bgMusicPlayer.pause()
            selectLevel(withName: node.name!)
        }else if node.name == "Config" && !configOpen{
            showSettingButtons()
        }else if node.name == "Config" && configOpen{
            hideSettingButtons()
        }else if node.name == "SoundsOn"{
            print("Sounds Off")
            soundsOn = false
            self.soundsOnButton?.zPosition = buttonsZPositionOff
            self.soundsOffButton?.zPosition = buttonsZPositionOn
        }else if node.name == "SoundsOff"{
            soundsOn = true
            self.soundsOnButton?.zPosition = buttonsZPositionOn
            self.soundsOffButton?.zPosition = buttonsZPositionOff
            
        }
        
    }
    func showSettingButtons(){
        configOpen = true
        self.configButton?.zPosition = buttonsZPositionOn
        if soundsOn {
            self.soundsOnButton?.zPosition = buttonsZPositionOn
        }else{
            self.soundsOffButton?.zPosition = buttonsZPositionOn
        }
    }
    func hideSettingButtons(){
        configOpen = false
        self.configButton?.zPosition = buttonsZPositionOn
        self.soundsOnButton?.zPosition = buttonsZPositionOff
        self.soundsOffButton?.zPosition = buttonsZPositionOff
    }
    
    func playBackgroundMusic()
    {
        if self.bgMusicPlayer == nil {
            
            let musicPath = Bundle.main.path(forResource: "Menu", ofType: "mp3")
            let musicUrl = URL(fileURLWithPath: musicPath!)
            
            self.bgMusicPlayer = try! AVAudioPlayer(contentsOf: musicUrl)
            
            self.bgMusicPlayer.numberOfLoops = -1 // tocar para sempre
            
            self.bgMusicPlayer.prepareToPlay()
        }
        
        self.bgMusicPlayer.pause()
        self.bgMusicPlayer.currentTime = 0
        self.bgMusicPlayer.play()
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
            //self.run(SKAction.playSoundFileNamed("JumpEnding", waitForCompletion: false))
            
        }
        if (contact.bodyA.categoryBitMask == GameElements.ground && contact.bodyB.categoryBitMask == GameElements.mainCharacter) {
            let mainCharacter = contact.bodyB.node as! MainCharacter
            mainCharacter.isJumping = false
            // self.run(SKAction.playSoundFileNamed("JumpEnding", waitForCompletion: false))
        }
        
        // Main Character and Portal
        if (contact.bodyA.categoryBitMask == GameElements.mainCharacter && contact.bodyB.categoryBitMask == GameElements.portalAztec) {
            self.playButton?.zPosition = 0
            print("entrei")
            
        }
        if (contact.bodyA.categoryBitMask == GameElements.portalAztec && contact.bodyB.categoryBitMask == GameElements.mainCharacter) {
            self.playButton?.zPosition = 0
            print("entrei")
        }
    }
    
    
}


