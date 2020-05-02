//
//  GameScene.swift
//  FlappyBird
//
//  Created by Brandon Plank on 12/2/19.
//  Modified by Thatcher Clough on 4/1/20.
//  Copyright (c) 2020 Brandon Plank. All rights reserved.
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
    var skyNodes = [SKSpriteNode]()

    let verticalPipeGap: CGFloat = 130.0
    var moving = SKNode()
    var pipes = SKNode()

    var score = 0 {
        didSet { scoreLabelNode.text = String(score); scoreLabelNodeInside.text = String(score) }
    }

    var playSounds = true
    var newBirds = true

    var firstTouch = false
    var playFlapSound = false
    var afterGameOver = false
    var gameOverDisplayed = false
    var hitGround = false
    var hitPlayButton = false
    var hitSettingsButton = false
    var hitGithubButton = false

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

    lazy var flappybird = SKSpriteNode(texture: SKTexture(imageNamed: "flappybird").then { $0.filteringMode = .nearest }).then { $0.setScale(1.5)
        $0.position = CGPoint(x: width / 2, y: (height / 2) + 200)
    }

    lazy var getReady = SKSpriteNode(texture: SKTexture(imageNamed: "get-ready").then { $0.filteringMode = .nearest }).then { $0.setScale(1.2)
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

    lazy var settingsNode = SettingsPanel().then {
        $0.setScale(1.2)
        $0.zPosition = GamezPosition.resultText + 4
        $0.position = CGPoint(x: width / 2, y: (height / 2) + 15)
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
    
    let floatUpAndDown = SKAction.sequence([
        SKAction.moveBy(x: 0, y: 15, duration: 0.5),
        SKAction.moveBy(x: 0, y: -15, duration: 0.5)
    ])

    func setRandomBirdTextures() {
        let rand = Float.random(in: 0 ..< 1)
        for n in 0...2 {
            if newBirds {
                if rand < 0.1583 {
                    birdTextures[n] = SKTexture(imageNamed: "yellow-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                } else if rand < 0.3166 {
                    birdTextures[n] = SKTexture(imageNamed: "red-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                } else if rand < 0.475 {
                    birdTextures[n] = SKTexture(imageNamed: "blue-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                } else if rand < 0.6333 {
                    birdTextures[n] = SKTexture(imageNamed: "green-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                }else if rand < 0.7916 {
                    birdTextures[n] = SKTexture(imageNamed: "peach-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                }else if rand < 0.95 {
                    birdTextures[n] = SKTexture(imageNamed: "purple-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                } else {
                    birdTextures[n] = SKTexture(imageNamed: "kup-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                }
            } else {
                if rand < 0.33 {
                    birdTextures[n] = SKTexture(imageNamed: "yellow-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                } else if rand < 0.66 {
                    birdTextures[n] = SKTexture(imageNamed: "red-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                } else {
                    birdTextures[n] = SKTexture(imageNamed: "blue-bird-\(n + 1)").then { $0.filteringMode = .nearest }
                }
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

    lazy var settingsButton = SKSpriteNode(texture: SKTexture(imageNamed: "settings").then { $0.filteringMode = .nearest }).then {
        $0.name = "settings"
        $0.setScale(1.2)
        $0.position = CGPoint(x: (width / 2) + 80, y: (height / 2) - 125)
    }

    lazy var githubButton = SKSpriteNode(texture: SKTexture(imageNamed: "github").then { $0.filteringMode = .nearest }).then {
        $0.name = "github"
        $0.setScale(1.2)
        $0.position = CGPoint(x: (width / 2), y: (height / 2) - 25)
    }

    func setGravityAndPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -10.0)
        physicsWorld.contactDelegate = self
    }

    func setMoving() {
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

    func setRandomSkyTexture() {
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
                $0.position = CGPoint(x: CGFloat(i) * ($0.width - 1), y: $0.height / 3.5 + groundTexture.height * 2.0)
                $0.run(moveSkySpritesForever)
            }
            if skyNodes.count < 2 + Int(width / skyWidth) {
                skyNodes.append(spriteNode)
            } else {
                skyNodes[i].removeFromParent()
                skyNodes[i] = spriteNode
            }
            moving.addChild(spriteNode)
        }
    }

    func spawnPipesForever() {
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
        if UserDefaults.standard.object(forKey: "playSounds") == nil {
            UserDefaults.standard.set(true, forKey: "playSounds")
        }
        playSounds = UserDefaults.standard.bool(forKey: "playSounds")
        if playSounds {
            settingsNode.soundToggle.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.soundToggleY)
        } else {
            settingsNode.soundToggle.position = CGPoint(x: SettingsPositions.toggleOffX, y: SettingsPositions.soundToggleY)
        }
        
        if UserDefaults.standard.object(forKey: "newBirds") == nil {
            UserDefaults.standard.set(true, forKey: "newBirds")
        }
        newBirds = UserDefaults.standard.bool(forKey: "newBirds")
        if newBirds {
            settingsNode.newBirdsToggle.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.newBirdsToggleY)
        } else {
            settingsNode.newBirdsToggle.position = CGPoint(x: SettingsPositions.toggleOffX, y: SettingsPositions.newBirdsToggleY)
        }

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
        addChild(settingsButton)
        addChild(githubButton)
        
        score = 0
        moving.speed = 1
        bird.speed = 1
        pipes.setScale(0)
        
        bird.run(SKAction.repeatForever(floatUpAndDown), withKey:"float")

        ControlCentre.subscrpt(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchedNodeName = atPoint(touch.location(in: self)).name

        if touchedNodeName == "play" && !hitPlayButton {
            hitPlayButton = true
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { self.playButton.setScale(1.15) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run { self.playButton.setScale(1.2) },
                SKAction.wait(forDuration: 0.1)]),
                completion: {
                    if self.afterGameOver {
                        self.resetScene()
                        self.afterGameOver = false
                    } else {
                        self.bird.removeAction(forKey: "float")
                        self.addChild(self.taptap)
                        self.addChild(self.getReady)
                        self.addChild(self.scoreLabelNode)
                        self.addChild(self.scoreLabelNodeInside)
                        self.bird.position = CGPoint(x: self.width / 2.5, y: self.height / 2)
                        self.flappybird.removeFromParent()
                    }
                    self.bird.run(SKAction.repeatForever(self.floatUpAndDown), withKey: "float")
                    self.playButton.removeFromParent()
                    self.settingsButton.removeFromParent()
                    self.githubButton.removeFromParent()

                    self.hitPlayButton = false
                    self.firstTouch = true
                }
            )
        } else if touchedNodeName == "settings" && !hitSettingsButton {
            hitSettingsButton = true
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { self.settingsButton.setScale(1.15) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run { self.settingsButton.setScale(1.2) },
                SKAction.wait(forDuration: 0.1)]),
                completion: {
                    self.scaleTwice(node: self.playButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    self.scaleTwice(node: self.settingsButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    if self.afterGameOver {
                        self.scaleTwice(node: self.resultNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    } else {
                        self.scaleTwice(node: self.bird, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                        self.scaleTwice(node: self.githubButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    }
                    
                    self.settingsNode.setScale(0)
                    self.addChild(self.settingsNode)
                    self.scaleTwice(node: self.settingsNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    
                    self.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.run{self.hitSettingsButton = false}]))
                }
            )
        } else if touchedNodeName == "toggleSounds" {
            if playSounds {
                settingsNode.soundToggle.run(SKAction.sequence([
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOffX + 6, y: SettingsPositions.soundToggleY), duration: 0.08),
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOffX, y: SettingsPositions.soundToggleY), duration: 0.12)
                ]))
                
                playSounds = false
                UserDefaults.standard.set(false, forKey: "playSounds")
                UserDefaults.standard.synchronize()
            } else {
                settingsNode.soundToggle.run(SKAction.sequence([
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOnX - 6, y: SettingsPositions.soundToggleY), duration: 0.08),
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.soundToggleY), duration: 0.12)
                ]))
                
                playSounds = true
                UserDefaults.standard.set(true, forKey: "playSounds")
                UserDefaults.standard.synchronize()
                playSound(sound: swooshAction)
            }
        } else if touchedNodeName == "toggleNewBirds" {
            playSound(sound: swooshAction)
            if newBirds {
                 settingsNode.newBirdsToggle.run(SKAction.sequence([
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOffX + 6, y: SettingsPositions.newBirdsToggleY), duration: 0.08),
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOffX, y: SettingsPositions.newBirdsToggleY), duration: 0.12)
                ]))
                
                newBirds = false
                UserDefaults.standard.set(false, forKey: "newBirds")
                UserDefaults.standard.synchronize()
            } else {
                settingsNode.newBirdsToggle.run(SKAction.sequence([
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOnX - 6, y: SettingsPositions.newBirdsToggleY), duration: 0.08),
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.newBirdsToggleY), duration: 0.12)
                ]))
                
                newBirds = true
                UserDefaults.standard.set(true, forKey: "newBirds")
                UserDefaults.standard.synchronize()
            }
        } else if touchedNodeName == "settingsBack" {
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { self.settingsNode.backButton.setScale(0.8) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run { self.settingsNode.backButton.setScale(1.0) },
                SKAction.wait(forDuration: 0.1)]),
                completion: {
                    self.scaleTwice(node: self.settingsNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    self.settingsNode.removeFromParent()
                    self.scaleTwice(node: self.playButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    self.scaleTwice(node: self.settingsButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.25, secondScaleDuration: 0.1)
                    
                    if self.afterGameOver {
                        self.scaleTwice(node: self.resultNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    } else {
                        self.scaleTwice(node: self.bird, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.5, secondScaleDuration: 0.1)
                        self.scaleTwice(node: self.githubButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    }
                }
            )
        } else if touchedNodeName == "github" && !hitGithubButton {
            self.hitGithubButton = true
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { self.githubButton.setScale(1.15) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run { self.githubButton.setScale(1.2) },
                SKAction.wait(forDuration: 0.9)]),
                completion: {
                    guard let url = URL(string: "https://www.github.com/brandonplank/flappybird") else { return }
                    UIApplication.shared.open(url)
                    self.hitGithubButton = false
                }
            )
        } else if firstTouch {
            bird.removeAction(forKey: "float")
            taptap.removeFromParent()
            getReady.removeFromParent()

            pipes.setScale(1)

            bird.physicsBody?.isDynamic = true
            firstTouch = false
            playFlapSound = true
        }

        if playFlapSound {
            playSound(sound: flapAction)
        }

        ControlCentre.trigger(.touch(touch))
    }

    override func update(_ currentTime: TimeInterval) {
        if hitGround { return }

        let value = bird.physicsBody!.velocity.dy * (bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001)
        bird.run(SKAction.rotate(toAngle: max(-1.57, value), duration: 0.08))
        if value < -0.7 {
            bird.speed = 1.75
        } else {
            bird.speed = 1
        }
    }

    @objc private func touchAction() {
        if !isUserInteractionEnabled { return }
        if bird.position.y >= self.frame.height {
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

        playSound(sound: hitAction)
        run(SKAction.wait(forDuration: TimeInterval(UInt32(0.5))))
        playSound(sound: dieAction)
        
        scoreLabelNode.removeFromParent()
        scoreLabelNodeInside.removeFromParent()

        gameover.setScale(0)
        addChild(gameover)
        scaleTwice(node: gameover, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.24, secondScaleDuration: 0.1)
        
        moving.speed = 0
    }

    func addResultsAndButtons() {
        resultNode.setScale(0)
        resultNode.score = score
        addChild(resultNode)
        scaleTwice(node: resultNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.25, secondScaleDuration: 0.1)

        playButton.setScale(0)
        addChild(playButton)
        scaleTwice(node: playButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)

        settingsButton.setScale(0)
        addChild(settingsButton)
        scaleTwice(node: settingsButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)

        afterGameOver = true
    }

    func playSound(sound: SKAction) {
        if playSounds {
            DispatchQueue.main.async {
                self.run(sound)
            }
        }
    }
    
    func scaleTwice(node: SKNode, firstScale: CGFloat, firstScaleDuration: TimeInterval, secondScale: CGFloat, secondScaleDuration: TimeInterval) {
        node.run(SKAction.sequence([
            SKAction.scale(to: firstScale, duration: firstScaleDuration),
            SKAction.scale(to: secondScale, duration: secondScaleDuration)
        ]))
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

            self.playSound(sound: self.pointAction)

            scaleTwice(node: scoreLabelNode, firstScale: 1.5, firstScaleDuration: 0.1, secondScale: 1.0, secondScaleDuration: 0.1)
            scaleTwice(node: scoreLabelNodeInside, firstScale: 1.5, firstScaleDuration: 0.1, secondScale: 1.0, secondScaleDuration: 0.1)
        } else if !gameOverDisplayed && ((contact.bodyA.categoryBitMask & PhysicsCatagory.pipe) == PhysicsCatagory.pipe || (contact.bodyB.categoryBitMask & PhysicsCatagory.pipe) == PhysicsCatagory.pipe) {
            gameOver()
        } else if !hitGround && (contact.bodyA.categoryBitMask & PhysicsCatagory.land) == PhysicsCatagory.land || (contact.bodyB.categoryBitMask & PhysicsCatagory.land) == PhysicsCatagory.land {
            hitGround = true
            bird.speed = 0.5

            if !gameOverDisplayed {
                gameOver()
            }

            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

            let addResultNode = SKAction.run {
                self.playSound(sound: self.swooshAction)
                self.addResultsAndButtons()
                self.isUserInteractionEnabled = true
            }
            run(SKAction.sequence([SKAction.wait(forDuration: 0.8), SKAction.run { self.bird.speed = 0 }, SKAction.wait(forDuration: 0.2), addResultNode]))
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
