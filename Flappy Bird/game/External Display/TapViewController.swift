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
        let restartBtn: UIButton = {
            let button = UIButton(type: .roundedRect)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(restart), for: .touchUpInside)
            button.setTitle("Restart", for: .normal)
            return button
        }()
        view.addSubview(restartBtn)
        NSLayoutConstraint.activate([
            restartBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restartBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
        ])
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        ControlCentre.trigger(.touch(touch))

        let dot: UIView = {
            let view = UIView()
            view.isUserInteractionEnabled = false
            view.backgroundColor = .lightGray
            view.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            view.layer.cornerRadius = 20
            view.layer.masksToBounds = true
            view.center = touch.location(in: view)
            return view
        }()
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
