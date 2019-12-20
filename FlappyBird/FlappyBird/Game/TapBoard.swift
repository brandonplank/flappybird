//
//  TapBoard.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/17/19.
//  Copyright © 2019 Brandon Plank. All rights reserved.
//

import SpriteKit

class TapBoard: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(score: Int) {
        let image = SKTexture(imageNamed: "tap").then { $0.filteringMode = .nearest }
        self.init(texture: image, color: UIColor.clear, size: image.size())
    }
}
