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
import GameplayKit
import Then

class GameViewController: UIViewController {
    
    func getKillswitch() -> Bool {
        return UserDefaults.standard.bool(forKey: "killswitch")
    }
    
    func setKillswitch(_ what: Bool) {
        UserDefaults.standard.set(what, forKey: "killswitch")
        UserDefaults.standard.synchronize()
    }
    
    func getKillswitchText() -> String {
        return UserDefaults.standard.string(forKey: "killswitchtxt")!
    }
    
    func setKillswitchText(_ what: String) {
        UserDefaults.standard.set(what, forKey: "killswitchtxt")
        UserDefaults.standard.synchronize()
    }
    
    func setKillswitchTextFromURL(){
        if let url = URL(string: "https://flappyapp.org/contents/killswitchtxt.txt") {
            do {
                let contents = try String(contentsOf: url)
                setKillswitchText(contents)
            } catch {
                if (UserDefaults.standard.object(forKey: "killswitchtxt") == nil){
                    setKillswitchText("A killswitch has been activated. App will now close.")
                }
            }
        } else {
            if (UserDefaults.standard.object(forKey: "killswitchtxt") == nil){
                setKillswitchText("A killswitch has been activated. App will now close.")
            }
        }
    }
    
    override var shouldAutorotate: Bool { false }
    override var prefersStatusBarHidden: Bool { true }
    override var canBecomeFirstResponder: Bool { true }
    var preferredFramesPerSecond: Int { 120 }
    
    lazy var scene = GameScene(fileNamed: "GameScene")?.then {
        $0.scaleMode = .aspectFill
    }
    
    override func loadView() {
        checkKillswitch()
        view = SKView().then {
            $0.ignoresSiblingOrder = true
            $0.showsFPS = false
            $0.showsNodeCount = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let scene = scene, let skView = self.view as? SKView else { return }
        skView.presentScene(scene)
        becomeFirstResponder()
        
        if (getKillswitch() == true){
            print("The killswitch is active")
            setKillswitchTextFromURL()
            
            let alert = UIAlertController(title: "Killswitch", message: getKillswitchText(), preferredStyle: .alert)
            let exitButton = UIAlertAction(title: "Exit", style: .default, handler: { action in
                exit(0)
            })
            alert.addAction(exitButton)
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        } else {
            print("The killswitch is not active")
        }
    }
    
    func checkKillswitch(){
        if let url = URL(string: "https://flappyapp.org/contents/killswitch.txt") {
            do {
                let contents = try String(contentsOf: url)
                if (contents == "no\n"){
                    print("Setting killswitch to false")
                    setKillswitch(false)
                }
                if (contents == "yes\n"){
                    print("Setting killswitch to true")
                    setKillswitch(true)
                }
            } catch {
                print("Could not get killswitch data")
            }
        } else {
            print("Could not get killswitch data")
        }
    }
}
