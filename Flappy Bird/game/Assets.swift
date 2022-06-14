//
//  Assets.swift
//  Flappy Bird
//
//  Created by Brandon Plank on 10/1/21.
//  Copyright © 2021 Brandon Plank & Thatcher Clough. All rights reserved.
//

import Foundation
import SpriteKit

class Assets {
    static let shared = Assets()
    let sprites = SKTextureAtlas(named: "textures")

    func preloadAssets() {
        sprites.preload {
            #if DEBUG
            print("Sprites preloaded")
            #endif
        }
    }
}
