
//
//  ResultBoard.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Modified by ThathcerDev on 3/22/20.
//  Copyright (c) 2016 Brandon Plank. All rights reserved.
//

import SpriteKit

class ResultBoard: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(score: Int) {
        let image = SKTexture(imageNamed: "scoreboard").then { $0.filteringMode = .nearest }
        self.init(texture: image, color: UIColor.clear, size: image.size())
        
        addChild(new)
        addChild(currentScore)
        addChild(bestScore)
        addChild(currentScoreInside)
        addChild(bestScoreInside)
        addChild(medal)
        self.score = score
        currentScore.position = CGPoint(x: frame.midX + 75, y: frame.midY + 7)
        bestScore.position = CGPoint(x: frame.midX + 75, y: frame.midY - 35)
        currentScoreInside.position = CGPoint(x: frame.midX + 75, y: frame.midY + 7)
        bestScoreInside.position = CGPoint(x: frame.midX + 75, y: frame.midY - 35)
        medal.position = CGPoint(x: frame.midX - 64, y: frame.midY - 6)
        new.position = CGPoint(x: frame.midX + 35, y: frame.midY - 6)
    }
    
    private lazy var currentScore = SKLabelNode(fontNamed: "04b_19").then {
        $0.zPosition = GamezPosition.resultText + 1
        $0.fontSize = 16
        $0.fontColor = SKColor.black
    }

    private lazy var currentScoreInside = SKLabelNode(fontNamed: "inside").then {
        $0.zPosition = GamezPosition.resultText
        $0.fontSize = 16
        $0.fontColor = SKColor.white
    }

    private lazy var bestScore = SKLabelNode(fontNamed: "04b_19").then {
        $0.zPosition = GamezPosition.resultText + 1
        $0.fontSize = 16
        $0.fontColor = SKColor.black
    }

    private lazy var bestScoreInside = SKLabelNode(fontNamed: "inside").then {
        $0.zPosition = GamezPosition.resultText
        $0.fontSize = 16
        $0.fontColor = SKColor.white
    }
    
    private lazy var medal = SKSpriteNode().then { medal in
        medal.zPosition = 1
    }
    
    private lazy var new = SKSpriteNode(texture: SKTexture(imageNamed: "new")).then { new in
        new.setScale(0)
        new.zPosition = 2
    }
    
    var score: Int = 0 {
        didSet {
            let newHighScore = score > ResultBoard.bestScore()
            
            if newHighScore {
                ResultBoard.setBestScore(score)
                new.setScale(1)
            } else {
                new.setScale(0)
            }
            
            currentScore.text = "\(score)"
            currentScoreInside.text = "\(score)"
            bestScore.text = "\(ResultBoard.bestScore())"
            bestScoreInside.text = "\(ResultBoard.bestScore())"
           
            let medalTexture = score < 10 ? (SKTexture(imageNamed: "copper-medal")) : (score < 20 ? (SKTexture(imageNamed: "silver-medal")) : (score < 50 ? (SKTexture(imageNamed: "gold-medal")) : (SKTexture(imageNamed: "platinum-medal"))))
            let action = SKAction.setTexture(medalTexture, resize: true)
            medal.run(action)
        }
    }
}

private extension ResultBoard {
    class func bestScore() -> Int {
        return UserDefaults.standard.integer(forKey: "bestScore")
    }

    class func setBestScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: "bestScore")
        UserDefaults.standard.synchronize()
    }
}
