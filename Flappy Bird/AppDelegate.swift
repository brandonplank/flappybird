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
func getKillswitchText() -> String {
    return UserDefaults.standard.string(forKey: "killswitchtxt")!
}

func setKillswitchText(_ what: String) {
    UserDefaults.standard.set(what, forKey: "killswitchtxt")
    UserDefaults.standard.synchronize()
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        //kill switch just in case of a copyright notice
        
        func getText(){
            if let url = URL(string: "https://flappyapp.org/hdsgaukfgjhdsghugujyadsgluyfgljasglfjsdgjfdgdsghgudsaiguyfguifegiutfgaitdgfyiauifudsyguasygbfyasguykdfaegbwkjrfbkjagbfutcwegautrfuwtbfuwtbeutirfiutawtgbuifyhusirefbguiygeryfysgfyusgeoyiifegyryiegufygruifysigeyigfes/killswitchtxt.txt") {
                do {
                    let contents = try String(contentsOf: url)
                    print(contents)
                    setKillswitchText(contents)
                } catch {
                    print("Failed")
                }
            } else {
                print("Failed")
            }
        }
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
                    getText()
                } else {
                    print("The killswitch is not active")
                    setKillswitch(false)
                    setKillswitchText("")
                }
            } catch {
                if (getKillswitch() == true){
                    print("The killswitch is active")
                    setKillswitch(true)
                    getText()
                    exit(0)
                } else {
                    print("The killswitch is not active")
                    setKillswitch(false)
                    setKillswitchText("")
                }
            }
        } else {
            if (getKillswitch() == true){
                print("The killswitch is active")
                setKillswitch(true)
                getText()
                exit(0)
            } else {
                print("The killswitch is not active")
                setKillswitch(false)
                setKillswitchText("")
            }
        }
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        return true
    }
}
