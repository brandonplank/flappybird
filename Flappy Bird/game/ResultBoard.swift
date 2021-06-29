
//
//  ResultBoard.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Modified by ThathcerDev on 3/22/20.
//  Copyright (c) 2016 Brandon Plank. All rights reserved.
//
import SpriteKit

public class ResultBoard: SKSpriteNode {
    
    public static var userUid: String?
    public static var userName: String?
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(score: Int) {
        let image = SKTexture(imageNamed: "scoreboard")
        image.filteringMode = .nearest
        self.init(texture: image, color: UIColor.clear, size: image.size())
        
        
        currentScore.position = CGPoint(x: frame.midX + 75, y: frame.midY + 7)
        currentScoreInside.position = CGPoint(x: frame.midX + 75 - 0.49, y: frame.midY + 7)
        bestScore.position = CGPoint(x: frame.midX + 75, y: frame.midY - 35)
        bestScoreInside.position = CGPoint(x: frame.midX + 75 - 0.49, y: frame.midY - 35)
        medal.position = CGPoint(x: frame.midX - 64, y: frame.midY - 6)
        new.position = CGPoint(x: frame.midX + 35, y: frame.midY - 6)
        
        bestScore.text = "\(ResultBoard.bestScore())"
        bestScoreInside.text = "\(ResultBoard.bestScore())"
        currentScore.text = "0"
        currentScoreInside.text = "0"
        
        addChild(new)
        new.setScale(0)
        addChild(sparkle)
        addChild(currentScore)
        addChild(bestScore)
        addChild(currentScoreInside)
        addChild(bestScoreInside)
        addChild(medal)
        self.score = score
    }

    private var currentScore: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "04b_19")
        node.zPosition = GamezPosition.resultText + 1
        node.fontSize = 16
        node.fontColor = SKColor.black
        return node
    }()
    
    private var currentScoreInside: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "inside")
        node.zPosition = GamezPosition.resultText
        node.fontSize = 16
        node.fontColor = SKColor.white
        return node
    }()

    private var bestScore: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "04b_19")
        node.zPosition = GamezPosition.resultText + 1
        node.fontSize = 16
        node.fontColor = SKColor.black
        return node
    }()

    private var bestScoreInside: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "inside")
        node.zPosition = GamezPosition.resultText
        node.fontSize = 16
        node.fontColor = SKColor.white
        return node
    }()
        
    private var medal: SKSpriteNode = {
        let node = SKSpriteNode()
        node.zPosition = GamezPosition.resultText
        return node
    }()

    private var new: SKSpriteNode = {
        let node = SKSpriteNode(texture: SKTexture(imageNamed: "new"))
        node.setScale(0)
        return node
    }()
  
    private var sparkle: SKSpriteNode = {
        let node = SKSpriteNode(texture: SKTexture(imageNamed: "sparkle"))
        node.setScale(0)
        node.zPosition = GamezPosition.resultText + 1
        return node
    }()
    
    private let sparkleAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.customAction(withDuration: 0.0) { (node, _) in
            let newX = CGFloat(Float.random(in: -88...(-40)))
            let newY = CGFloat(Float.random(in: -26...15))
            node.run(SKAction.move(to: CGPoint(x: newX, y: newY), duration: 0.0))
        },
        SKAction.scale(to: 0.7, duration: 0.3),
        SKAction.wait(forDuration: 0.5),
        SKAction.scale(to: 0.0, duration: 0.3)
    ]))
    
    var score: Int = 0 {
        didSet {
            if canShowScore {
                
                DispatchQueue.global().async {
                    let previousHighScore = ResultBoard.bestScore()
                    if(self.score > ResultBoard.bestScore()){
                        ResultBoard.setBestScore(self.score)
                    }
                    
                    self.currentScore.text = "0"
                    self.currentScoreInside.text = "0"
                    self.new.setScale(0)
                    
                    for i in 0 ... (self.score) {
                        if (self.score > 0) && (i != 0) {
                            usleep(UInt32(1.5/Double(self.score) * 1000000.0))
                        }
                        self.currentScore.text = "\(i)"
                        self.currentScoreInside.text = "\(i)"
                        if (i) > previousHighScore {
                            self.bestScore.text = "\(i)"
                            self.bestScoreInside.text = "\(i)"
                            if (i == self.score) {
                                self.new.run(SKAction.sequence([
                                    SKAction.scale(to: 0.7, duration: 0.05),
                                    SKAction.scale(to: 1.0, duration: 0.05)
                                ]))
                            }
                        }
                    }
                }
            }
            
            if canShowScore {
                let medalTexture = score == 0 ? SKTexture() : (score < (ResultBoard.bestScore() / 2) ? (SKTexture(imageNamed: "copper-medal")) : (score < ResultBoard.bestScore() ?(SKTexture(imageNamed: "silver-medal")) : (score < (ResultBoard.bestScore() * 2) ? (SKTexture(imageNamed: "gold-medal")) : (SKTexture(imageNamed:"platinum-medal")))))
                medal.run(SKAction.setTexture(medalTexture, resize: true))
                
                sparkle.setScale(0)
                sparkle.removeAllActions()
                if(score > 0){
                    sparkle.run(sparkleAction)
                }
            }
        }
    }
}

public extension ResultBoard {
    class func bestScore() -> Int {
        return UserDefaults.standard.integer(forKey: "bestScore")
    }
    
    class func setBestScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: "bestScore")
        UserDefaults.standard.synchronize()
    }
}
