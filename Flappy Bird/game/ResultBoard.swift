
//
//  ResultBoard.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Modified by ThathcerDev on 3/22/20.
//  Copyright (c) 2016 Brandon Plank. All rights reserved.
//

import SpriteKit
import Then
import Firebase
import Network
import SwiftKeychainWrapper

class ResultBoard: SKSpriteNode {
    
    let firebaseRef = Database.database().reference()
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        let moveRand = SKAction.customAction(withDuration: 0.0) { (node, _) in
            let newX = CGFloat(Float.random(in: -88...(-40)))
            let newY = CGFloat(Float.random(in: -26...15))
            node.run(SKAction.move(to: CGPoint(x: newX, y: newY), duration: 0.0))
        }
        
        sparkle.run(SKAction.repeatForever(SKAction.sequence([
            moveRand,
            SKAction.scale(to: 0.7, duration: 0.3),
            SKAction.wait(forDuration: 0.5),
            SKAction.scale(to: 0.0, duration: 0.3)
        ])))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(score: Int) {
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        var saveSuccessful: Bool
        var identifier: String
        
        let retrievedUUID: String? = KeychainWrapper.standard.string(forKey: "flappyUUID")
        if retrievedUUID == nil{
            saveSuccessful = KeychainWrapper.standard.set(uuid, forKey: "flappyUUID")
            identifier = retrievedUUID!
            print("Creating keychain")
        } else {
            identifier = retrievedUUID!
            print("Already have keychain")
        }
    
        let image = SKTexture(imageNamed: "scoreboard").then { $0.filteringMode = .nearest }
        self.init(texture: image, color: UIColor.clear, size: image.size())
        firebaseRef.child("Device scores/\(identifier)/score").observeSingleEvent(of: .value){
            (snapshot ) in
            let savedScore = snapshot.value as? Int
            DispatchQueue.main.async {
                if snapshot.exists(){
                    print("High Score: \(ResultBoard.bestScore())")
                    if (savedScore != nil){
                        print("Saved score: \(savedScore!)")
                        self.bestScore.text = "\(savedScore!)"
                        self.bestScoreInside.text = "\(savedScore!)"
                        ResultBoard.setBestScore(savedScore!)
                    }
                } else {
                    self.firebaseRef.child("Device scores/\(identifier)/score").setValue(score)
                }
            }
        }
        addChild(new)
        addChild(sparkle)
        addChild(currentScore)
        addChild(bestScore)
        addChild(currentScoreInside)
        addChild(bestScoreInside)
        addChild(medal)
        self.score = score
    }
    
    private lazy var currentScore = SKLabelNode(fontNamed: "04b_19").then {
        $0.zPosition = GamezPosition.resultText + 1
        $0.fontSize = 16
        $0.fontColor = SKColor.black
        $0.position = CGPoint(x: frame.midX + 75, y: frame.midY + 7)
    }
    
    private lazy var currentScoreInside = SKLabelNode(fontNamed: "inside").then {
        $0.zPosition = GamezPosition.resultText
        $0.fontSize = 16
        $0.fontColor = SKColor.white
        $0.position = CGPoint(x: frame.midX + 75, y: frame.midY + 7)
    }
    
    private lazy var bestScore = SKLabelNode(fontNamed: "04b_19").then {
        $0.zPosition = GamezPosition.resultText + 1
        $0.fontSize = 16
        $0.fontColor = SKColor.black
        $0.position = CGPoint(x: frame.midX + 75, y: frame.midY - 35)
    }
    
    private lazy var bestScoreInside = SKLabelNode(fontNamed: "inside").then {
        $0.zPosition = GamezPosition.resultText
        $0.fontSize = 16
        $0.fontColor = SKColor.white
        $0.position = CGPoint(x: frame.midX + 75, y: frame.midY - 35)
    }
    
    private lazy var medal = SKSpriteNode().then {
        $0.zPosition = GamezPosition.resultText
        $0.position = CGPoint(x: frame.midX - 64, y: frame.midY - 6)
    }
    
    private lazy var new = SKSpriteNode(texture: SKTexture(imageNamed: "new")).then {
        $0.zPosition = GamezPosition.resultText
        $0.position = CGPoint(x: frame.midX + 35, y: frame.midY - 6)
        $0.setScale(0)
    }
    
    private lazy var sparkle = SKSpriteNode(texture: SKTexture(imageNamed: "sparkle")).then {
        $0.setScale(0)
        $0.zPosition = GamezPosition.resultText+1
    }
    
    var score: Int = 0 {
        didSet {
            let uuid = UIDevice.current.identifierForVendor!.uuidString
            var saveSuccessful: Bool
            var identifier: String
            
            let retrievedUUID: String? = KeychainWrapper.standard.string(forKey: "flappyUUID")
            if retrievedUUID == nil{
                saveSuccessful = KeychainWrapper.standard.set(uuid, forKey: "flappyUUID")
                identifier = retrievedUUID!
                print("Creating keychain")
            } else {
                identifier = retrievedUUID!
                print("Already have keychain")
            }
            let newHighScore = score > ResultBoard.bestScore()
            let duration: Double = 1.5 //seconds
            
            bestScore.text = "0"
            bestScoreInside.text = "0"
            new.setScale(0) //always remove until called.
            if newHighScore {
                DispatchQueue.global().async {
                    for i in 0 ..< (self.score + 1) {
                        let sleepTime = UInt32(duration/Double(self.score) * 1000000.0)
                        DispatchQueue.main.async {
                            if (i >= ResultBoard.bestScore()){
                                self.bestScore.text = "\(i)"
                                self.bestScoreInside.text = "\(i)"
                                if i == self.score {
                                    self.new.run(SKAction.sequence([
                                        SKAction.scale(to: 0.7, duration: 0.05),
                                        SKAction.scale(to: 1.0, duration: 0.1)
                                    ]))
                                }
                            }
                        }
                        usleep(sleepTime)
                    }
                    ResultBoard.setBestScore(self.score)
                    (self.firebaseRef.child("Device scores/\(identifier)/score") as AnyObject).setValue(ResultBoard.bestScore())
                    self.firebaseRef.child("Device scores/\(identifier)/score").observeSingleEvent(of: .value){
                        (snapshot ) in let savedScore = snapshot.value as! Int
                        print("Saved score 2: \(savedScore)")
                        ResultBoard.setBestScore(savedScore)
                    }
                    
                }
            } else {
                new.setScale(0)
            }
            
            currentScore.text = "0"
            currentScoreInside.text = "0"
            DispatchQueue.global().async {
                for i in 0 ..< (self.score) {
                    let sleepTime = UInt32(duration/Double(self.score) * 1000000.0)
                    usleep(sleepTime)
                    DispatchQueue.main.async {
                        self.currentScore.text = "\(i + 1)"
                        self.currentScoreInside.text = "\(i + 1)"
                    }
                }
            }
            bestScore.text = "\(ResultBoard.bestScore())"
            bestScoreInside.text = "\(ResultBoard.bestScore())"
            
            let medalTexture = score < (ResultBoard.bestScore() / 2) ? (SKTexture(imageNamed: "copper-medal")) : (score < ResultBoard.bestScore() ?(SKTexture(imageNamed: "silver-medal")) : (score < (ResultBoard.bestScore() * 2) ? (SKTexture(imageNamed: "gold-medal")) : (SKTexture(imageNamed:"platinum-medal"))))
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
