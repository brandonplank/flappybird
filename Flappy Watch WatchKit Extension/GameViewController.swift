//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by Brandon Plank on 4/30/20.
//  Copyright © 2020 Brandon Plank & Thatcher Clough. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit
import WatchKit
import GameKit
import AVFoundation

class GameViewController: WKInterfaceController, WKCrownDelegate, SKSceneDelegate {
    @IBOutlet weak var skInterface: WKInterfaceSKScene!
    
    @IBOutlet weak var ge: WKLongPressGestureRecognizer!
    private var crownSensivity:Double = 3.0
    
    var gameScene:GameScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let app = Dynamic.PUICApplication.sharedPUICApplication()
        app._setStatusBarTimeHidden(true, animated: false, completion: nil)
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
            
            // start listening to crown
            crownSequencer.delegate = self
            crownSequencer.focus()
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 60
            
            gameScene = scene

        } else {
            print("error")
        }
        GameScene.hitButton = false
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(false)
        super.didDeactivate()
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
            
        // convert crown rotation to CGFloat
        let step   = NSNumber.init(value: rotationalDelta * crownSensivity).floatValue
        let cgStep = CGFloat(step)

        if (cgStep < -0.5 || cgStep > 0.5) {
            WKInterfaceDevice.current().play(.click)
            //gameScene.touchFigure(CGPoint(x: 0, y: 0))
        }
    }
    
    
    // TODO: Craft a function to calculate the correct coords for a touch.
    @IBAction func gesture(_ sender: WKLongPressGestureRecognizer) {

            switch sender.state {
            case .began:
                let location = sender.locationInObject()
                let screenBounds = WKInterfaceDevice.current().screenBounds
                //let newX = ((location.x / screenBounds.width) * (skInterface.scene?.size.width)!) - ((skInterface.scene?.size.width)! / 2)
                //let newY: Int = (-((location.y / screenBounds.height) * (skInterface.scene?.size.height)!) - ((skInterface.scene?.size.height)! / 2))
                
                
                
                gameScene.touchFigure(location)
            case .cancelled, .ended:
                break
            default:
                break
            }
        }
    
    // MARK: OLD, NEWER CODE is ^
//   @IBAction func handleSingleTap(tapGesture: WKTapGestureRecognizer) {
//        //let location = tapGesture.locationInObject()
//        //print("here, log: \(location)")
//        //let screenBounds = WKInterfaceDevice.current().screenBounds
//        //let newX = ((location.x / screenBounds.width) * (skInterface.scene?.size.width)!) - ((skInterface.scene?.size.width)! / 2)
//        //let newY = (((location.y / screenBounds.height) * (skInterface.scene?.size.height)!) - ((skInterface.scene?.size.height)!) / 2)
//        gameScene.touchFigure(CGPoint(x: 0, y: 0))
//    }
}
