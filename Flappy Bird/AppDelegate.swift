//
//  AppDelegate.swift
//  Flappy Bird
//
//  Created by Thatcher Clough on 4/30/20.
//  Copyright © 2020 Brandon Plank & Thatcher Clough. All rights reserved.
//

import UIKit
import AVFoundation
func getKillswitch() -> Bool {
    return UserDefaults.standard.bool(forKey: "killswitch")
}

func setKillswitch(_ what: Bool) {
    UserDefaults.standard.set(what, forKey: "killswitch")
    UserDefaults.standard.synchronize()
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        //kill switch just in case of a copyright notice
        if let url = URL(string: "https://flappyapp.org/hdsgaukfgjhdsghugujyadsgluyfgljasglfjsdgjfdgdsghgudsaiguyfguifegiutfgaitdgfyiauifudsyguasygbfyasguykdfaegbwkjrfbkjagbfutcwegautrfuwtbfuwtbeutirfiutawtgbuifyhusirefbguiygeryfysgfyusgeoyiifegyryiegufygruifysigeyigfes/killswitch.txt") {
            do {
                let contents = try String(contentsOf: url)
                print(contents)
                if (contents == "no\n"){
                    print("Setting killswitch to false")
                    setKillswitch(false)
                }
                if (contents == "yes\n"){
                    print("Setting killswitch to true")
                    setKillswitch(true)
                }
                if (getKillswitch() == true){
                    print("The killswitch is active")
                    setKillswitch(true)
                    exit(0)
                } else {
                    print("The killswitch is not active")
                    setKillswitch(false)
                }
            } catch {
                if (getKillswitch() == true){
                    print("The killswitch is active")
                    setKillswitch(true)
                    exit(0)
                } else {
                    print("The killswitch is not active")
                    setKillswitch(false)
                }
            }
        } else {
            if (getKillswitch() == true){
                print("The killswitch is active")
                setKillswitch(true)
                exit(0)
            } else {
                print("The killswitch is not active")
                setKillswitch(false)
            }
        }
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        return true
    }
}
