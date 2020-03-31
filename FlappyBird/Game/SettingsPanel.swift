//
//  SettingsPanel.swift
//  FlappyBird
//
//  Created by Thatcher Clough on 3/30/20.
//  Copyright © 2020 Brandon Plank. All rights reserved.
//

import Foundation
import SpriteKit

class SettingsPanel: SKSpriteNode {

    convenience init() {
        self.init(texture: SKTexture(imageNamed: "settings-panel").then { $0.filteringMode = .nearest })
        addChild(backButton)
        
        addChild(soundToggle)
        addChild(soundToggleBackground)
        addChild(soundButton)
        
        addChild(newBirdsToggle)
        addChild(newBirdsToggleBackground)
        addChild(newBirdsButton)
    }
    
    lazy var backButton = SKSpriteNode().then {
        $0.name = "settingsBack"
        $0.position = CGPoint(x: -70, y: 72)
        $0.zPosition = 1
        $0.color = UIColor.clear
        $0.size = CGSize(width: 80, height: 25)
    }
    
    lazy var soundToggle = SKSpriteNode(texture: SKTexture(imageNamed: "toggle").then { $0.filteringMode = .nearest }).then {
        $0.position = CGPoint(x: 83, y: 31.5)
        $0.zPosition = 2
    }
    
    lazy var soundToggleBackground = SKSpriteNode(texture: SKTexture(imageNamed: "toggle-background").then { $0.filteringMode = .nearest }).then {
        $0.position = CGPoint(x: 68.5, y: 31.5)
        $0.zPosition = 1
    }
    
    lazy var soundButton = SKSpriteNode().then {
        $0.name = "toggleSounds"
        $0.position = CGPoint(x: 68, y: 30)
        $0.zPosition = 3
        $0.color = UIColor.clear
        $0.size = CGSize(width: 57, height: 30)
    }
    
    lazy var newBirdsToggle = SKSpriteNode(texture: SKTexture(imageNamed: "toggle").then { $0.filteringMode = .nearest }).then {
        $0.position = CGPoint(x: 83, y: -28.5)
        $0.zPosition = 2
    }
    
    lazy var newBirdsToggleBackground = SKSpriteNode(texture: SKTexture(imageNamed: "toggle-background").then { $0.filteringMode = .nearest }).then {
        $0.position = CGPoint(x: 68.5, y: -28.5)
        $0.zPosition = 1
    }
    
    lazy var newBirdsButton = SKSpriteNode().then {
        $0.name = "toggleNewBirds"
        $0.position = CGPoint(x: 68, y: -30)
        $0.zPosition = 3
        $0.color = UIColor.clear
        $0.size = CGSize(width: 57, height: 30)
    }
}
