//
//  TapViewController.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Copyright (c) 2016 Brandon Plank. All rights reserved.
//
import UIKit

class TapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        let restartBtn = UIButton(type: .roundedRect).then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(restart), for: .touchUpInside)
            $0.setTitle("Restart", for: .normal)
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            restartBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restartBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
        ])
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        ControlCentre.trigger(.touch(touch))

        let dot = UIView().then {
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .lightGray
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            $0.layer.cornerRadius = 20
            $0.layer.masksToBounds = true
            $0.center = touch.location(in: view)
        }
        view.addSubview(dot)
        UIView.animate(withDuration: 0.6, animations: {
            dot.alpha = 0
            dot.transform = CGAffineTransform(scaleX: 5, y: 5)
        }) { finished in
            dot.removeFromSuperview()
        }
    }

    @objc func restart() {
        ControlCentre.trigger(.restart)
    }
}
