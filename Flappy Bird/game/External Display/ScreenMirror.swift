//
//  ScreenMirror.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Copyright (c) 2016 Brandon Plank. All rights reserved.
//

import UIKit

class ScreenMirror: NSObject {
    static let share = ScreenMirror()
    private var externalWindow: UIWindow?

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectNotification(_:)), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectNotification(_:)), name: UIScreen.didDisconnectNotification, object: nil)
    }

    func end() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didConnectNotification(_ noti: Notification) {
        guard let newScreen = noti.object as? UIScreen else { return }
        externalWindow =  {
            let window = UIWindow()
            window.frame = newScreen.bounds
            window.rootViewController = GameViewController()
            window.screen = newScreen
            window.isHidden = false
            return window
        }()
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = TapViewController()
    }

    @objc func didDisconnectNotification(_ noti: Notification) {
        externalWindow?.isHidden = true
        externalWindow = nil
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = GameViewController()
    }
}
