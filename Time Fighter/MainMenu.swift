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

class MainMenu: SKScene {
    var configOpen:Bool = false
    var soundsOn: Bool = true
    var configButton: SKSpriteNode?
    var soundsOnButton: SKSpriteNode?
    var soundsOffButton: SKSpriteNode?
    var logo: SKSpriteNode?
    
    let buttonsZPositionOn:CGFloat = 5
    let buttonsZPositionOff:CGFloat = -10
    
    var bgMusicPlayer: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        
        let button = SKSpriteNode(imageNamed: "playAztecWorld")
        button.position = CGPoint(x: 0, y: 100)
        button.name = "playAztecWorld"
        button.zPosition = 1
        
        
        logo = self.childNode(withName: "Logo") as! SKSpriteNode
        logo?.zPosition = buttonsZPositionOn
        
        configButton = self.childNode(withName: "Config") as! SKSpriteNode
        configButton?.zPosition = buttonsZPositionOn
        
        soundsOnButton = self.childNode(withName: "SoundsOn") as! SKSpriteNode
        soundsOnButton?.zPosition  = buttonsZPositionOff
        soundsOffButton = self.childNode(withName: "SoundsOff") as! SKSpriteNode
        soundsOffButton?.zPosition = buttonsZPositionOff
        
        let levelSelectionBackgroung = self.childNode(withName: "FullLevelSelection")
        levelSelectionBackgroung?.addChild(button)
        
        self.playBackgroundMusic()
    }
    
    func createLevelSceneWithLevel(level: String) -> SKScene? {
        var levelScene: SKScene?
        switch level {
        case "playAztecWorld":
            levelScene = SKScene(fileNamed: "GameScene")
            print("Gamescene")
        case "MainMenu":
            print("Menu")
        //levelScene = level
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
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        let node =  self.atPoint(location)
        
        // If next button is touched, start transition to second scene
        if (node.name == "playAztecWorld") {
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
    
    
}


