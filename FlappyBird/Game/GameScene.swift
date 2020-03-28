//
//  GameScene.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Modified by Thatcher Clough on 3/22/20.
//  Copyright (c) 2016 Brandon Plank. All rights reserved.
//

import AVFoundation
import SpriteKit

extension SKTexture {
    var width: CGFloat { size().width }
    var height: CGFloat { size().height }
}

extension SKNode {
    var width: CGFloat { frame.width }
    var height: CGFloat { frame.height }
}

struct PhysicsCatagory {
    static let bird: UInt32 = 0x1 << 0
    static let land: UInt32 = 0x1 << 1
    static let pipe: UInt32 = 0x1 << 2
    static let score: UInt32 = 0x1 << 3
}

struct GamezPosition {
    static let sky: CGFloat = -3
    static let pipe: CGFloat = -2
    static let bird: CGFloat = -1
    static let land: CGFloat = 0
    static let score: CGFloat = 1
    static let result: CGFloat = 2
    static let resultText: CGFloat = 3
}

class GameScene: SKScene {
    let impact = UIImpactFeedbackGenerator()
    
    let flapAction = SKAction.playSoundFileNamed("sounds/sfx_wing.caf", waitForCompletion: false)
    let dieAction = SKAction.playSoundFileNamed("sounds/sfx_die.caf", waitForCompletion: false)
    let pointAction = SKAction.playSoundFileNamed("sounds/sfx_point.wav", waitForCompletion: false)
    let hitAction = SKAction.playSoundFileNamed("sounds/sfx_hit.caf", waitForCompletion: false)
    let swooshAction = SKAction.playSoundFileNamed("sounds/sfx_swooshing.caf", waitForCompletion: false)

    let pipeTextureUp = SKTexture(imageNamed: "PipeUp").then { $0.filteringMode = .nearest }
    let pipeTextureDown = SKTexture(imageNamed: "PipeDown").then { $0.filteringMode = .nearest }
    let groundTexture = SKTexture(imageNamed: "land").then { $0.filteringMode = .nearest }
    var birdTextures = [SKTexture(), SKTexture(), SKTexture()]
    var skyNodes = [SKSpriteNode(), SKSpriteNode(),SKSpriteNode(),SKSpriteNode()]
    
    let verticalPipeGap: CGFloat = 130.0
    var moving = SKNode()
    var pipes = SKNode()
    
    var score = 0 {
        didSet { scoreLabelNode.text = String(score); scoreLabelNodeInside.text = String(score) }
    }
    
    var firstTouch = false
    var playFlapSound = false
    var afterGameOver = false
    var gameOverDisplayed = false
    var hitGround = false
    
    lazy var scoreLabelNode = SKLabelNode(fontNamed: "04b_19").then {
        $0.fontColor = SKColor.black
        $0.fontSize = 50
        $0.position = CGPoint(x: width / 2, y: 3 * height / 4)
        $0.zPosition = GamezPosition.score
    }

    lazy var scoreLabelNodeInside = SKLabelNode(fontNamed: "inside").then {
        $0.fontColor = SKColor.white
        $0.fontSize = 50
        $0.position = CGPoint(x: width / 2 - 1.5, y: 3 * height / 4)
        $0.zPosition = GamezPosition.score
    }
    
    lazy var gameover = SKSpriteNode(texture: SKTexture(imageNamed: "gameover").then { $0.filteringMode = .nearest }).then {
        $0.setScale(1.5)
        $0.zPosition = GamezPosition.score
        $0.position = CGPoint(x: width / 2, y: (height / 2) + 210)
    }
    
    lazy var flappybird = SKSpriteNode(texture: SKTexture(imageNamed: "flappybird").then { $0.filteringMode = .nearest }).then {         $0.setScale(1.5)
        $0.position = CGPoint(x: width / 2, y: (height / 2) + 200)
    }
    
    lazy var getReady = SKSpriteNode(texture: SKTexture(imageNamed: "get-ready").then { $0.filteringMode = .nearest }).then {         $0.setScale(1.2)
        $0.position = CGPoint(x: width / 2, y: (height / 2) + 130)
    }
    
    lazy var taptap = SKSpriteNode(texture: SKTexture(imageNamed: "taptap").then { $0.filteringMode = .nearest }).then {
        $0.setScale(1.5)
        $0.position = CGPoint(x: width / 2, y: height / 2)
    }
    
    lazy var resultNode = ResultBoard(score: score).then {
        $0.zPosition = GamezPosition.result
        $0.position = CGPoint(x: width / 2, y: (height / 2) + 50)
    }
    
    lazy var bird = SKSpriteNode(texture: SKTexture(imageNamed: "yellow-bird-1").then { $0.filteringMode = .nearest }).then {
        $0.setScale(1.5)
        $0.zPosition = GamezPosition.bird
        $0.position = CGPoint(x: (width / 2), y: (height / 2) + 75)
        $0.physicsBody = SKPhysicsBody(circleOfRadius: $0.height / 2.0).then {
            $0.isDynamic = false
            $0.categoryBitMask = PhysicsCatagory.bird
            $0.collisionBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
            $0.contactTestBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
        }
    }
    
    func setRandomBirdTextures(){
        let rand = Float.random(in: 0 ... 1)
        for n in 0...2 {
            if rand < 0.2375 {
                birdTextures[n] = SKTexture(imageNamed: "yellow-bird-\(n+1)").then { $0.filteringMode = .nearest }
            } else if rand < 0.475 {
                birdTextures[n] = SKTexture(imageNamed: "red-bird-\(n+1)").then { $0.filteringMode = .nearest }
            } else if rand < 0.7125 {
                birdTextures[n] = SKTexture(imageNamed: "blue-bird-\(n+1)").then { $0.filteringMode = .nearest }
            } else if rand < 0.95 {
                birdTextures[n] = SKTexture(imageNamed: "purple-bird-\(n+1)").then { $0.filteringMode = .nearest }
            } else {
                birdTextures[n] = SKTexture(imageNamed: "kup-bird-\(n+1)").then { $0.filteringMode = .nearest }
            }
        }
        let anim = SKAction.animate(with: [birdTextures[0], birdTextures[1], birdTextures[2], birdTextures[1]], timePerFrame: 0.1)
        bird.run(SKAction.repeatForever(anim))
    }
    
    lazy var ground = SKNode().then {
        $0.position = CGPoint(x: 0, y: groundTexture.height)
        $0.zPosition = GamezPosition.land
        $0.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: groundTexture.height * 2.0)).then {
            $0.isDynamic = false
            $0.categoryBitMask = PhysicsCatagory.land
        }
    }
    
    lazy var playButton = SKSpriteNode(texture: SKTexture(imageNamed: "play").then { $0.filteringMode = .nearest }).then {
        $0.name = "play"
        $0.setScale(1.2)
        $0.position = CGPoint(x: (width / 2) - 80, y: (height / 2) - 125)
    }
    
    lazy var githubButton = SKSpriteNode(texture: SKTexture(imageNamed: "github").then { $0.filteringMode = .nearest }).then { github in
        github.name = "github"
        github.setScale(1.2)
        github.position = CGPoint(x: (width / 2) + 80, y: (height / 2) - 125)
    }
    
    func setGravityAndPhysics(){
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -10.0)
        physicsWorld.contactDelegate = self
    }
    
    func setMoving(){
        let groundWidth = groundTexture.width * 2.0
        let moveGroundSprite = SKAction.moveBy(x: -groundWidth, y: 0, duration: TimeInterval(0.005 * groundWidth))
        let resetGroundSprite = SKAction.moveBy(x: groundWidth, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        for i in 0..<2 + Int(width / groundWidth) {
            moving.addChild(SKSpriteNode(texture: groundTexture).then {
                $0.setScale(2.0)
                $0.position = CGPoint(x: CGFloat(i) * $0.width, y: $0.height / 2.0)
                $0.run(moveGroundSpritesForever)
            })
        }
    }
    
    func setRandomSkyTexture(){
        let rand = Float.random(in: 0 ..< 1)
        let skyTexture = rand < 0.5 ? SKTexture(imageNamed: "night-sky") : SKTexture(imageNamed: "day-sky")
        
        let skyWidth = skyTexture.width * 1.5
        let moveSkySprite = SKAction.moveBy(x: -skyWidth, y: 0, duration: TimeInterval(0.1 * skyWidth))
        let resetSkySprite = SKAction.moveBy(x: skyWidth, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        for i in 0..<2 + Int(width / skyWidth) {
            let spriteNode = SKSpriteNode(texture: skyTexture).then {
                $0.setScale(1.5)
                $0.zPosition = GamezPosition.sky
                $0.position = CGPoint(x: CGFloat(i) * $0.width, y: $0.height / 3.5 + groundTexture.height * 2.0)
                $0.run(moveSkySpritesForever)
            }
            if skyNodes[i].parent != nil {
                skyNodes[i].removeFromParent()
            }
            skyNodes[i].removeFromParent()
            moving.addChild(spriteNode)
            skyNodes[i] = spriteNode
        }
    }
    
    func spawnPipesForever(){
        let spawn = SKAction.run(spawnPipes)
        let delay = SKAction.wait(forDuration: 1.0)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(spawnThenDelay))
    }
    
    private func spawnPipes() {
        let height = UInt32(self.height / 4)
        let y = CGFloat(arc4random_uniform(height) + height)
        let pipeDown = SKSpriteNode(texture: pipeTextureDown).then {
            $0.setScale(2.0)
            $0.position = CGPoint(x: 0.0, y: y + $0.height + verticalPipeGap)
            $0.physicsBody = SKPhysicsBody(rectangleOf: $0.size).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCatagory.pipe
                $0.contactTestBitMask = PhysicsCatagory.bird
            }
        }
        let pipeUp = SKSpriteNode(texture: pipeTextureUp).then {
            $0.setScale(2.0)
            $0.position = CGPoint(x: 0.0, y: y)
            $0.physicsBody = SKPhysicsBody(rectangleOf: $0.size).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCatagory.pipe
                $0.contactTestBitMask = PhysicsCatagory.bird
            }
        }
        let contactNode = SKNode().then {
            $0.position = CGPoint(x: pipeDown.width - 60 + bird.width / 2, y: self.height / 2)
            let size = CGSize(width: pipeUp.width, height: self.height)
            $0.physicsBody = SKPhysicsBody(rectangleOf: size).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCatagory.score
                $0.contactTestBitMask = PhysicsCatagory.bird
            }
        }

        // the pipes move actions
        let distanceToMove = width + 2.0 * pipeTextureUp.width
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.005 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        let movePipesAndRemove = SKAction.sequence([movePipes, removePipes])

        pipes.addChild(SKNode().then {
            $0.position = CGPoint(x: width + pipeTextureUp.width * 2, y: 0)
            $0.zPosition = GamezPosition.pipe
            $0.addChild(pipeDown)
            $0.addChild(pipeUp)
            $0.addChild(contactNode)
            $0.run(movePipesAndRemove)
        })
    }
    
    override func didMove(to view: SKView) {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        
        setGravityAndPhysics()
        setMoving()
        setRandomSkyTexture()
        setRandomBirdTextures()
        spawnPipesForever()
        
        addChild(flappybird)
        addChild(moving)
        moving.addChild(pipes)
        addChild(bird)
        addChild(ground)
        addChild(playButton)
        addChild(githubButton)
        
        score = 0
        moving.speed = 1
        bird.speed = 1
        pipes.setScale(0)

        ControlCentre.subscrpt(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchedNodeName = atPoint(touch.location(in: self)).name
        
        if touchedNodeName == "play" {
            run(SKAction.sequence([
                SKAction.run {
                    DispatchQueue.main.async {
                        self.run(self.swooshAction)
                    }
                },
                SKAction.run {self.playButton.setScale(1.15)},
                SKAction.wait(forDuration: 0.1),
                SKAction.run {self.playButton.setScale(1.2)},
                SKAction.wait(forDuration: 0.1)]),
                completion: {
                    if self.afterGameOver {
                        self.resetScene()
                        self.afterGameOver = false
                    } else {
                        self.addChild(self.taptap)
                        self.addChild(self.getReady)
                        self.addChild(self.scoreLabelNode)
                        self.addChild(self.scoreLabelNodeInside)
                        self.bird.position = CGPoint(x: self.width / 2.5, y: self.height / 2)
                        self.flappybird.removeFromParent()
                    }
                    self.playButton.removeFromParent()
                    self.githubButton.removeFromParent()
                    
                    self.firstTouch = true
                }
            )
        } else if touchedNodeName == "github" {
            run(SKAction.sequence([
                SKAction.run {
                    DispatchQueue.main.async {
                        self.run(self.swooshAction)
                    }
                },
                SKAction.run {self.githubButton.setScale(1.15)},
                SKAction.wait(forDuration: 0.1),
                SKAction.run {self.githubButton.setScale(1.2)},
                SKAction.wait(forDuration: 0.9)]),
                completion: {
                    guard let url = URL(string: "https://www.github.com/brandonplank/flappybird") else { return }
                    UIApplication.shared.open(url)
                }
            )
        } else if firstTouch {
            taptap.removeFromParent()
            getReady.removeFromParent()
            
            pipes.setScale(1)
            
            bird.physicsBody?.isDynamic = true
            firstTouch = false
            playFlapSound = true
        }
        
        if playFlapSound {
            DispatchQueue.main.async {
                self.run(self.flapAction)
            }
        }
        
        ControlCentre.trigger(.touch(touch))
    }

    override func update(_ currentTime: TimeInterval) {
        if hitGround { return }
        
        let value = bird.physicsBody!.velocity.dy * (bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001)
        bird.run(SKAction.rotate(toAngle: max(-1.57, value), duration: 0.05))
        if value < -0.7 {
            bird.speed = 1.75
        } else {
            bird.speed = 1
        }
    }

    @objc private func touchAction() {
        if !isUserInteractionEnabled { return }
        if bird.position.y >= self.frame.height{
            bird.position.y = self.frame.height
        }
        
        if moving.speed > 0 {
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        }
    }

    func resetScene() {
        pipes.removeAllChildren()
        resultNode.removeFromParent()
        gameover.removeFromParent()
        
        setRandomSkyTexture()
        setRandomBirdTextures()
        
        addChild(taptap)
        addChild(getReady)
        addChild(scoreLabelNode)
        addChild(scoreLabelNodeInside)
        
        gameOverDisplayed = false
        hitGround = false
        pipes.setScale(0)
        score = 0
        moving.speed = 1
        bird.speed = 1 
        bird.zRotation = 0.0
        bird.position = CGPoint(x: width / 2.5, y: height / 2)
        bird.physicsBody?.do {
            $0.isDynamic = false
            $0.velocity = CGVector(dx: 0, dy: 0)
            $0.collisionBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
        }
    }

    func gameOver() {
        isUserInteractionEnabled = false
        gameOverDisplayed = true
        playFlapSound = false
        
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.collisionBitMask = PhysicsCatagory.land
        bird.physicsBody?.isDynamic = true
        let anim = SKAction.animate(with: [birdTextures[0], birdTextures[1], birdTextures[2], birdTextures[1]], timePerFrame: 0.1)
        bird.run(SKAction.repeatForever(anim))
        
        DispatchQueue.main.async {
            self.run(self.hitAction)
            sleep(UInt32(0.5))
            self.run(self.dieAction)
        }
        
        scoreLabelNode.removeFromParent()
        scoreLabelNodeInside.removeFromParent()
        
        gameover.setScale(0)
        addChild(gameover.then {
            $0.run(SKAction.sequence([
                SKAction.scale(to: 1, duration: 0.1),
                SKAction.scale(to: 1.25, duration: 0.1),
            ]))
        })
        
        moving.speed = 0
    }
    
    func addResultsAndButtons() {
        resultNode.setScale(0)
        addChild(resultNode.then {
            $0.score = score
            $0.run(SKAction.sequence([
                SKAction.scale(to: 1, duration: 0.1),
                SKAction.scale(to: 1.25, duration: 0.1),
            ]))
        })
        
        playButton.setScale(0)
        addChild(playButton.then {
           $0.run(SKAction.sequence([
                SKAction.scale(to: 1, duration: 0.1),
                SKAction.scale(to: 1.2, duration: 0.1),
            ]))
        })
        
        githubButton.setScale(0)
        addChild(githubButton.then{
            $0.run(SKAction.sequence([
                SKAction.scale(to: 1, duration: 0.1),
                SKAction.scale(to: 1.2, duration: 0.1),
            ]))
        })
        
        afterGameOver = true
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if (bird.speed == 1 || bird.speed == 1.75) && !gameOverDisplayed && ((contact.bodyA.categoryBitMask & PhysicsCatagory.score) == PhysicsCatagory.score || (contact.bodyB.categoryBitMask & PhysicsCatagory.score) == PhysicsCatagory.score) {
            score += 1
            
            if score == 1000 {
                guard let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ") else { return }
                UIApplication.shared.open(url)
            }
            
            impact.impactOccurred()
            
            DispatchQueue.main.async {
                self.run(self.pointAction)
            }

            scoreLabelNode.run(SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1),
            ]))

            scoreLabelNodeInside.run(SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1),
            ]))
        } else if !gameOverDisplayed && ((contact.bodyA.categoryBitMask & PhysicsCatagory.pipe) == PhysicsCatagory.pipe || (contact.bodyB.categoryBitMask & PhysicsCatagory.pipe) == PhysicsCatagory.pipe) {
            gameOver()
        } else if !hitGround && (contact.bodyA.categoryBitMask & PhysicsCatagory.land) == PhysicsCatagory.land || (contact.bodyB.categoryBitMask & PhysicsCatagory.land) == PhysicsCatagory.land  {
            hitGround = true
            bird.speed = 0.5
            
            if !gameOverDisplayed {
                gameOver()
            }
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

            let addResultNode = SKAction.run {
                DispatchQueue.main.async {
                    self.run(self.swooshAction)
                }
                self.addResultsAndButtons()
                self.isUserInteractionEnabled = true
            }
            run(SKAction.sequence([SKAction.wait(forDuration: 0.8), SKAction.run{self.bird.speed = 0}, SKAction.wait(forDuration: 0.2), addResultNode]))
        }
    }
}

extension GameScene: ControlCentreDelegate {
    func callback(_ event: EventType) {
        switch event {
        case .touch:
            touchAction()
        case .restart:
            resetScene()
        }
    }
}
