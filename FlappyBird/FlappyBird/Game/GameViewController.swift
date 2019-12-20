//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Copyright (c) 2016 Brandon Plank. All rights reserved.
//

import SpriteKit
import UIKit

class GameViewController: UIViewController {
    override var shouldAutorotate: Bool { true }
    override var prefersStatusBarHidden: Bool { true }
    override var canBecomeFirstResponder: Bool { true }
    var preferredFramesPerSecond: Int { 400 }

    override var keyCommands: [UIKeyCommand]? { [
        UIKeyCommand(input: "j", modifierFlags: .command, action: #selector(commandAction(_:)), discoverabilityTitle: "Jump"),
        UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(commandAction(_:)), discoverabilityTitle: "Restart"),
    ] }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

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

    @objc func commandAction(_ command: UIKeyCommand) {
        if command.input == "j" {
            ControlCentre.trigger(.touch(nil))
        } else if command.input == "r" {
            ControlCentre.trigger(.restart)
        }
    }
}
