//
//  AppDelegate.swift
//  Flappy Bird
//
//  Created by Thatcher Clough on 4/30/20.
//  Copyright © 2020 Brandon Plank & Thatcher Clough. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        //kill switch just in case of a copyright notice
        if let url = URL(string: "https://flappyapp.org/hdsgaukfgjhdsghugujyadsgluyfgljasglfjsdgjfdgdsghgudsaiguyfguifegiutfgaitdgfyiauifudsyguasygbfyasguykdfaegbwkjrfbkjagbfutcwegautrfuwtbfuwtbeutirfiutawtgbuifyhusirefbguiygeryfysgfyusgeoyiifegyryiegufygruifysigeyigfes/killswitch.txt") {
            do {
                let contents = try String(contentsOf: url)
                print(contents)
                if contents == "yes\n"{
                    print("The killswitch is active")
                    exit(0)
                } else {
                    print("The killswitch is not active")
                }
            } catch {
                print("Failed to load the killswitch address. Not doing anything.")
            }
        } else {
           print("Failed to load the killswitch address. Not doing anything.")
        }
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        return true
    }
}
