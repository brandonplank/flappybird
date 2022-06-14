//
//  LoadingViewController.swift
//  Flappy Bird
//
//  Created by Brandon Plank on 6/11/22.
//  Copyright © 2022 Brandon Plank & Thatcher Clough. All rights reserved.
//

import Foundation
import UIKit
import Sentry

class LoadingViewController: UIViewController {
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Showing launch screen")
        infoLabel.text = """
Flappy Bird \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
Copyright © 2019 - \(Calendar.current.component(.year, from: Date()))
crypticplank, ThatcherDev

See license for details.
"""
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            DispatchQueue.main.async {
                self.progressLabel.text = "Loading Sentry"
                SentrySDK.start { options in
                    options.dsn = "https://991041777f23449d8f13e438d7911c1f@o956450.ingest.sentry.io/5983798"
                    options.tracesSampleRate = 0.5
                    options.debug = false
                }
            }
            DispatchQueue.main.async {
                self.progressLabel.text = "Preloading sprites"
                Assets.shared.preloadAssets()
            }
            DispatchQueue.main.async {
                self.progressLabel.text = "Done"
            }
            sleep(2)
            DispatchQueue.main.async {
                let gameViewController = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
                gameViewController.modalPresentationStyle = .fullScreen
                gameViewController.modalTransitionStyle = .crossDissolve
                        
                self.present(gameViewController, animated: true, completion: nil)
            }
        }
    }
}
