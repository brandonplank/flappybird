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
import Sentry
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        IQKeyboardManager.shared.enable = true
        // Assets.shared.preloadAssets()
        
        // Allow background audio playback
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        
//        SentrySDK.start { options in
//            options.dsn = "https://991041777f23449d8f13e438d7911c1f@o956450.ingest.sentry.io/5983798"
//            options.tracesSampleRate = 0.5
//            options.debug = false
//        }
        
        return true
    }
}
