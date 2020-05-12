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
    
    var btnSignIn : UIButton!
    
    @objc func btnSignInPressed() {
        GIDSignIn.sharedInstance().signIn()
    }


    
    var global_msg: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        //Firebase stuff
        let firebaseRef = Database.database().reference()
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Network is connected");
                firebaseRef.child("Killswitch").observeSingleEvent(of: .value){
                    (snapshot ) in let killswitch = snapshot.value as! Bool
                    self.setKillswitch(killswitch)
                    return
                }
                
                firebaseRef.child("Killswitch Message").observeSingleEvent(of: .value){
                    (snapshot ) in let message = snapshot.value as! String
                    self.setKillswitchText(message)
                }
                
                firebaseRef.child("Latest Version").observeSingleEvent(of: .value){
                    (snapshot ) in let latestVersion = snapshot.value as! String
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
            }
            
            if(self.getKillswitch()){
                print("The killswitch is active")
                let message = self.getKillswitchText()
                if (message == ""){
                    self.global_msg = "A killswitch has been activated. App will now close."
                } else {
                    self.global_msg = message
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
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        guard let scene = scene, let skView = self.view as? SKView else { return }
        skView.presentScene(scene)
        becomeFirstResponder()
    }
}
