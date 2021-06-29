//
//  SettingsPanel.swift
//  FlappyBird
//
//  Created by Thatcher Clough on 3/30/20.
//  Copyright © 2020 Brandon Plank. All rights reserved.
//
import Foundation
import SpriteKit

struct SettingsPositions {
    static let toggleOnX: CGFloat = 68
    static let toggleOffX: CGFloat = 46
    
    static let soundToggleY: CGFloat = 60
    static let newBirdsToggleY: CGFloat = 24
    static let hapticsToggleY: CGFloat = -12
    static let adaptiveBackgroundToggleY: CGFloat = -56
    
    static let backButtonX: CGFloat = -92
    static let backButtonY: CGFloat = 85
}

class SettingsPanel: SKSpriteNode {
    
    convenience init() {
        let texture = SKTexture(imageNamed: "settings-panel")
        texture.filteringMode = .nearest
        self.init(texture: texture)
        addChild(backButton)
        addChild(backButtonTouchBox)
        
        addChild(soundToggle)
        addChild(soundButton)
        
        addChild(newBirdsToggle)
        addChild(newBirdsButton)
        
        addChild(hapticsToggle)
        addChild(hapticsButton)
        
        addChild(adaptiveBackgroundToggle)
        addChild(adaptiveBackgroundButton)
    }
    
    var backButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "back-button")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.position = CGPoint(x: SettingsPositions.backButtonX, y: SettingsPositions.backButtonY)
        node.zPosition = 1
        return node
    }()
    
    var backButtonTouchBox: SKSpriteNode = {
        let node = SKSpriteNode()
        node.name = "settingsBack"
        node.zPosition = 2
        node.position = CGPoint(x: SettingsPositions.backButtonX, y: SettingsPositions.backButtonY)
        node.color = UIColor.clear
        node.size = CGSize(width: 30, height: 30)
        return node
    }()
    
    var soundToggle: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "toggle")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.soundToggleY)
        node.zPosition = 2
        return node
    }()
    
    var soundButton: SKSpriteNode = {
        let node = SKSpriteNode()
        node.name = "toggleSounds"
        node.zPosition = 3
        node.position = CGPoint(x: SettingsPositions.toggleOffX + (SettingsPositions.toggleOnX - SettingsPositions.toggleOffX) / 2, y: SettingsPositions.soundToggleY)
        node.color = UIColor.clear
        node.size = CGSize(width: 45, height: 45)
        return node
    }()
    
    var newBirdsToggle: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "toggle")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.newBirdsToggleY)
        node.zPosition = 2
        return node
    }()
    
    var newBirdsButton: SKSpriteNode = {
        let node = SKSpriteNode()
        node.name = "toggleNewBirds"
        node.zPosition = 3
        node.position = CGPoint(x: SettingsPositions.toggleOffX + (SettingsPositions.toggleOnX - SettingsPositions.toggleOffX) / 2, y: SettingsPositions.newBirdsToggleY)
        node.color = UIColor.clear
        node.size = CGSize(width: 45, height: 25)
        return node
    }()
        
    var hapticsToggle: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "toggle")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.hapticsToggleY)
        node.zPosition = 2
        return node
    }()
    
    var hapticsButton: SKSpriteNode = {
        let node = SKSpriteNode()
        node.name = "toggleHaptics"
        node.position = CGPoint(x: SettingsPositions.toggleOffX + (SettingsPositions.toggleOnX - SettingsPositions.toggleOffX) / 2, y: SettingsPositions.hapticsToggleY)
        node.zPosition = 3
        node.color = UIColor.clear
        node.size = CGSize(width: 45, height: 25)
        return node
    }()
    
    var adaptiveBackgroundToggle: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "toggle")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.adaptiveBackgroundToggleY)
        node.zPosition = 2
        return node
    }()
    
    var adaptiveBackgroundButton: SKSpriteNode = {
        let node = SKSpriteNode()
        node.name = "toggleAdaptiveBackground"
        node.position = CGPoint(x: SettingsPositions.toggleOffX + (SettingsPositions.toggleOnX - SettingsPositions.toggleOffX) / 2, y: SettingsPositions.adaptiveBackgroundToggleY)
        node.zPosition = 3
        node.color = UIColor.clear
        node.size = CGSize(width: 45, height: 25)
        return node
    }()
}
