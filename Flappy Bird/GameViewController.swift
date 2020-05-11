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
import Firebase
import Network
import GoogleSignIn

let gameVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

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
    
    override var shouldAutorotate: Bool { false }
    override var prefersStatusBarHidden: Bool { true }
    override var canBecomeFirstResponder: Bool { true }
    var preferredFramesPerSecond: Int { 120 }
    
    lazy var scene = GameScene(fileNamed: "GameScene")?.then {
        $0.scaleMode = .aspectFill
    }
    
    override func loadView() {
        view = SKView().then {
            $0.ignoresSiblingOrder = true
            $0.showsFPS = false
            $0.showsNodeCount = false
        }
    }
    var global_msg: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        let signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        signInButton.center = view.center
        view.addSubview(signInButton)
        
        
        
        guard let scene = scene, let skView = self.view as? SKView else { return }
        skView.presentScene(scene)
        becomeFirstResponder()
        //Firebase stuff

        let firebaseRef = Database.database().reference()

        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Network is connected");
                firebaseRef.child("Killswitch").observeSingleEvent(of: .value){
                    (snapshot ) in let isOn = snapshot.value as! Bool
                    if (isOn == false){
                        print("Setting killswitch to false")
                        self.setKillswitch(false)
                        return
                    }
                    if (isOn == true) || (self.getKillswitch() == true){
                        print("Setting killswitch to true")
                        self.setKillswitch(true)
                        print("The killswitch is active")
                        firebaseRef.child("Killswitch Message").observeSingleEvent(of: .value){
                            (snapshot ) in let message = snapshot.value as! String
                            if (message == ""){
                                self.setKillswitchText("A killswitch has been activated. App will now close.")
                            } else {
                                self.global_msg = message
                                print(self.global_msg!)
                                self.setKillswitchText(self.global_msg!)
                                let alert = UIAlertController(title: "Killswitch", message: self.global_msg, preferredStyle: .alert)
                                let exitButton = UIAlertAction(title: "Exit", style: .default, handler: { action in
                                    exit(0)
                                })
                                alert.addAction(exitButton)
                                DispatchQueue.main.async(execute: {
                                    self.present(alert, animated: true)
                                })
                            }
                        }
                    }
                }
                //Check For updates.
                firebaseRef.child("Latest Version").observeSingleEvent(of: .value){
                    (snapshot ) in let latestVersion = snapshot.value as! String
                    print(gameVersion!)
                    if (gameVersion! < latestVersion){
                        let alert = UIAlertController(title: "Update", message: "Game version \(latestVersion) is avalible, please update to the latest version for the newest features and bug fixes!\nOffical downloads from\nhttps://flappyapp.org\nor\nhttps://github.com/brandonplank/flappybird", preferredStyle: .alert)
                        let exitButton = UIAlertAction(title: "Ok", style: .default, handler: { action in
                            self.dismiss(animated: true)
                        })
                        alert.addAction(exitButton)
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true)
                        })
                    }
                }
            } else {
                print("No network connected");
                if (self.getKillswitch() == true){
                        print("Setting killswitch to true")
                        self.setKillswitch(true)
                        print("The killswitch is active")
                        if (self.getKillswitchText() == ""){
                            self.setKillswitchText("A killswitch has been activated. App will now close.")
                            self.global_msg = self.getKillswitchText()
                        } else {
                            let alert = UIAlertController(title: "Killswitch", message: self.getKillswitchText(), preferredStyle: .alert)
                            let exitButton = UIAlertAction(title: "Exit", style: .default, handler: { action in
                                exit(0)
                            })
                            alert.addAction(exitButton)
                            DispatchQueue.main.async(execute: {
                                self.present(alert, animated: true)
                        })
                    }
                }
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
