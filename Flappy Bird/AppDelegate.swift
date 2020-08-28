//
//  AppDelegate.swift
//  Flappy Bird
//
//  Created by Thatcher Clough on 4/30/20.
//  Copyright © 2020 Brandon Plank & Thatcher Clough. All rights reserved.
//
import UIKit
import AVFoundation
import Foundation
import SpriteKit

var isInstalledWithCydia = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Allow background audio playback
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        return true
    }
}
