//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by Thatcher Clough on 4/30/20.
//  Copyright © 2020 Brandon Plank & Thatcher Clough. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Then

class GameViewController: UIViewController {
       override var shouldAutorotate: Bool { false }
       override var prefersStatusBarHidden: Bool { true }
       override var canBecomeFirstResponder: Bool { true }
       var preferredFramesPerSecond: Int { 60 }

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

       override func viewDidLoad() {
           super.viewDidLoad()
           guard let scene = scene, let skView = self.view as? SKView else { return }
           skView.presentScene(scene)
           becomeFirstResponder()
       }
}
