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
import Network

let gameVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String


class GameViewController: UIViewController {
    public static let shared = GameViewController()
    
    public func getKillswitch() -> Bool {
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
    
    override var shouldAutorotate: Bool { false }
    override var prefersStatusBarHidden: Bool { true }
    override var canBecomeFirstResponder: Bool { true }
    var preferredFramesPerSecond: Int { 120 }
    
    lazy var scene = GameScene(fileNamed: "GameScene")?.then {
        $0.scaleMode = .aspectFill
    }
    
    override var keyCommands: [UIKeyCommand]? { [
        UIKeyCommand(input: "j", modifierFlags: .command, action: #selector(commandAction(_:)), discoverabilityTitle: "Jump"),
        UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(commandAction(_:)), discoverabilityTitle: "Restart"),
    ] }
    
    override func loadView() {
        view = SKView().then {
            $0.ignoresSiblingOrder = true
            $0.showsFPS = false
            $0.showsNodeCount = false
        }
    }
    override func viewWillLayoutSubviews() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork() {
            /*
            firebaseRef.child("Latest Version").observeSingleEvent(of: .value){
                (snapshot ) in let latestVersion = snapshot.value as! String
                if (gameVersion! < latestVersion){
                    firebaseRef.child("Update Required").observeSingleEvent(of: .value){
                        (snapshot ) in let update = snapshot.value as! Bool
                        if update {
                            let alert = UIAlertController(title: "Required Update", message: "Game version \(latestVersion) is avalible, please update to the latest version for the newest features and bug fixes!\nOfficial downloads from\nhttps://flappyapp.org\nor\nhttps://github.com/brandonplank/flappybird\nor\nhttps://app.eonhubapp.com", preferredStyle: .alert)
                            
                            let exitButton = UIAlertAction(title: "Exit", style: .default, handler: { action in
                                self.dismiss(animated: true)
                                exit(0)
                            })
                            
                            alert.addAction(exitButton)
                            DispatchQueue.main.async(execute: {
                                if self.presentedViewController != nil{
                                    self.presentedViewController?.dismiss(animated: true, completion: {
                                        self.present(alert, animated: true)
                                    })
                                } else {
                                    self.present(alert, animated: true)
                                }
                            })
                        } else {
                            let alert = UIAlertController(title: "Update", message: "Game version \(latestVersion) is avalible, please update to the latest version for the newest features and bug fixes!\nOfficial downloads from\nhttps://flappyapp.org\nor\nhttps://github.com/brandonplank/flappybird\nor\nhttps://app.eonhubapp.com", preferredStyle: .alert)
                            
                            let exitButton = UIAlertAction(title: "Ok", style: .default, handler: { action in
                                self.dismiss(animated: true)
                            })
                            
                            alert.addAction(exitButton)
                            DispatchQueue.main.async(execute: {
                                if self.presentedViewController != nil{
                                    self.presentedViewController?.dismiss(animated: true, completion: {
                                        self.present(alert, animated: true)
                                    })
                                } else {
                                    self.present(alert, animated: true)
                                }
                            })
                        }
                    }
                }
                firebaseRef.child("Killswitch Message").observeSingleEvent(of: .value){
                    (snapshot ) in let message = snapshot.value as! String
                    self.setKillswitchText(message)
                }
                
                firebaseRef.child("Killswitch").observeSingleEvent(of: .value){
                    (snapshot ) in let killswitch = snapshot.value as! Bool
                    if killswitch {
                        firebaseRef.child("Killswitch upto").observeSingleEvent(of: .value){
                            (snapshot ) in let inOnVersion = snapshot.value as! String
                            if gameVersion! <= inOnVersion {
                                //Display
                                print("Setting killswitch to true")
                                self.setKillswitch(killswitch)
                                self.doKillswitch()
                            }
                        }
                    } else {
                        print("Setting killswitch to false")
                        self.setKillswitch(false)
                        self.doKillswitch()
                    }
                }
            }
 */
        } else {
            doKillswitch()
        }
        
        guard let scene = scene, let skView = self.view as? SKView else { return }
        skView.presentScene(scene)
        becomeFirstResponder()
        
        GameScene.hitButton = false
    }
    
    func doKillswitch(){
        if(self.getKillswitch()){
            var message = self.getKillswitchText()
            if (message == ""){
                message = "A killswitch has been activated. App will now close."
            }
            
            let alert = UIAlertController(title: "Killswitch", message: message, preferredStyle: .alert)
            let exitButton = UIAlertAction(title: "Exit", style: .default, handler: { action in
                exit(0)
            })
            alert.addAction(exitButton)
            DispatchQueue.main.async(execute: {
                if self.presentedViewController != nil{
                    self.presentedViewController?.dismiss(animated: true, completion: {
                        self.present(alert, animated: true)
                    })
                } else {
                    self.present(alert, animated: true)
                }
            })
        }
    }
    
    @objc func commandAction(_ command: UIKeyCommand) {
        if command.input == "j" {
            ControlCentre.trigger(.touch(nil))
        } else if command.input == "r" {
            ControlCentre.trigger(.restart)
        }
    }
}
