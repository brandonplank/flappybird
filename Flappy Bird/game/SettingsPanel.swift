//
//  SettingsPanel.swift
//  FlappyBird
//
//  Created by Thatcher Clough on 3/30/20.
//  Copyright © 2020 Brandon Plank. All rights reserved.
//

import Foundation
import SpriteKit
import Then

struct SettingsPositions {
    static let toggleOnX: CGFloat = 66
    static let toggleOffX: CGFloat = 46
    
    static let soundToggleY: CGFloat = 17.5
    static let newBirdsToggleY: CGFloat = -18.5
    
    static let backButtonX: CGFloat = -92
    static let backButtonY: CGFloat = 44
}

class SettingsPanel: SKSpriteNode {

    convenience init() {
        self.init(texture: SKTexture(imageNamed: "settings-panel").then { $0.filteringMode = .nearest })
        addChild(backButton)
        addChild(backButtonTouchBox)

        addChild(soundToggle)
        addChild(soundButton)
        
        addChild(newBirdsToggle)
        addChild(newBirdsButton)
    }
    
    lazy var backButton = SKSpriteNode(texture: SKTexture(imageNamed: "back-button").then { $0.filteringMode = .nearest }).then {
        $0.position = CGPoint(x: SettingsPositions.backButtonX, y: SettingsPositions.backButtonY)
        $0.zPosition = 1
    }
    
    lazy var backButtonTouchBox = SKSpriteNode().then {
        $0.name = "settingsBack"
        $0.zPosition = 2
        $0.position = CGPoint(x: SettingsPositions.backButtonX, y: SettingsPositions.backButtonY)
        $0.color = UIColor.clear
        $0.size = CGSize(width: 30, height: 30)
    }
    
    lazy var soundToggle = SKSpriteNode(texture: SKTexture(imageNamed: "toggle").then { $0.filteringMode = .nearest }).then {
        $0.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.soundToggleY)
        $0.zPosition = 2
    }
    
    lazy var soundButton = SKSpriteNode().then {
        $0.name = "toggleSounds"
        $0.position = CGPoint(x: SettingsPositions.toggleOffX + (SettingsPositions.toggleOnX - SettingsPositions.toggleOffX) / 2, y: SettingsPositions.soundToggleY)
        $0.zPosition = 3
        $0.color = UIColor.clear
        $0.size = CGSize(width: 45, height: 25)
    }
    
    lazy var newBirdsToggle = SKSpriteNode(texture: SKTexture(imageNamed: "toggle").then { $0.filteringMode = .nearest }).then {
        $0.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.newBirdsToggleY)
        $0.zPosition = 2
    }
    
    lazy var newBirdsButton = SKSpriteNode().then {
        $0.name = "toggleNewBirds"
        $0.position = CGPoint(x: SettingsPositions.toggleOffX + (SettingsPositions.toggleOnX - SettingsPositions.toggleOffX) / 2, y: SettingsPositions.newBirdsToggleY)
        $0.zPosition = 3
        $0.color = UIColor.clear
        $0.size = CGSize(width: 45, height: 25)
    }
}
