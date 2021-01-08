//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by Thatcher Clough on 4/30/20.
//  Copyright © 2020 Brandon Plank & Thatcher Clough. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit
import WatchKit
import GameKit

class GameViewController: WKInterfaceController, WKCrownDelegate, SKSceneDelegate {
    @IBOutlet weak var skInterface: WKInterfaceSKScene!
    
    private var crownSensivity:Double = 20.0
    
    var gameScene:GameScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
            
            gameScene = scene
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 60

        } else {
            print("error")
        }
        GameScene.hitButton = false
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    // TODO: Add a proper touch function...
    @IBAction func handleSingleTap(tapGesture: WKTapGestureRecognizer) {
        //let location = tapGesture.locationInObject()
        //print("here, log: \(location)")
        //let screenBounds = WKInterfaceDevice.current().screenBounds
        //let newX = ((location.x / screenBounds.width) * (skInterface.scene?.size.width)!) - ((skInterface.scene?.size.width)! / 2)
        //let newY = (((location.y / screenBounds.height) * (skInterface.scene?.size.height)!) - ((skInterface.scene?.size.height)!) / 2)
        gameScene.touchFigure(CGPoint(x: 0, y: 0))
    }
}
