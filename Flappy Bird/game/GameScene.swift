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
import SceneKit

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

public class screenData {
    static let shared = screenData()
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    private init() { }
}

var canShowScore = true

class GameScene: SKScene {
    
    static let shared = GameScene()
    static let width = GameScene().width
    static let height = GameScene().height
    let impact = UIImpactFeedbackGenerator()
    
    let flapAction = SKAction.playSoundFileNamed("sounds/sfx_wing.caf", waitForCompletion: false)
    let dieAction = SKAction.playSoundFileNamed("sounds/sfx_die.caf", waitForCompletion: false)
    let pointAction = SKAction.playSoundFileNamed("sounds/sfx_point.wav", waitForCompletion: false)
    let hitAction = SKAction.playSoundFileNamed("sounds/sfx_hit.caf", waitForCompletion: false)
    let swooshAction = SKAction.playSoundFileNamed("sounds/sfx_swooshing.caf", waitForCompletion: false)
    
    let pipeTextureUp: SKTexture = {
        let texture = SKTexture(imageNamed: "PipeUp")
        texture.filteringMode = .nearest
        return texture
    }()
    let pipeTextureDown: SKTexture = {
        let texture = SKTexture(imageNamed: "PipeDown")
        texture.filteringMode = .nearest
        return texture
    }()
    let groundTexture: SKTexture = {
        let texture = SKTexture(imageNamed: "land")
        texture.filteringMode = .nearest
        return texture
    }()
    var birdTextures = [SKTexture(), SKTexture(), SKTexture()]
    var skyNodes = [SKSpriteNode]()
    
    var verticalPipeGap: CGFloat = 130.0
    var moving = SKNode()
    var pipes = SKNode()
    
    var score = 0 {
        didSet { scoreLabelNode.text = String(score); scoreLabelNodeInside.text = String(score) }
    }
    
    var playSounds = true
    var newBirds = true
    var haptics = true
    var adaptiveBackground = false
    
    var firstTouch = false
    var playFlapSound = false
    var afterGameOver = false
    var gameOverDisplayed = false
    var hitGround = false
    static var hitButton = true
    
    var time: Double = 0.0
    
    let notification = UINotificationFeedbackGenerator()
    
    lazy var scoreLabelNode: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "04b_19")
        node.fontColor = SKColor.black
        node.fontSize = 50
        node.position = CGPoint(x: width / 2, y: 3 * height / 4)
        node.zPosition = GamezPosition.score + 1
        return node
    }()
    
    lazy var scoreLabelNodeInside: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "inside")
        node.fontColor = SKColor.white
        node.fontSize = 50
        node.position = CGPoint(x: width / 2 - 1.5, y: 3 * height / 4)
        node.zPosition = GamezPosition.score
        return node
    }()
    
    lazy var gameover: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "gameover")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.setScale(1.5)
        node.zPosition = GamezPosition.score
        node.position = CGPoint(x: width / 2, y: (height / 2) + 210)
        return node
    }()
    
    lazy var flappybird: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "flappybird")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.setScale(1.5)
        node.position = CGPoint(x: width / 2, y: (height / 2) + 200)
        return node
    }()
    
    lazy var getReady: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "get-ready")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.setScale(1.2)
        node.position = CGPoint(x: width / 2, y: (height / 2) + 130)
        return node
    }()
  
    lazy var taptap: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "taptap")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.setScale(1.5)
        node.position = CGPoint(x: width / 2, y: height / 2)
        return node
    }()
    
    lazy var resultNode: ResultBoard = {
        let board = ResultBoard(score: score)
        board.zPosition = GamezPosition.result
        board.position = CGPoint(x: width / 2, y: (height / 2) + 75)
        return board
    }()
        
    lazy var settingsNode: SettingsPanel = {
        let panel = SettingsPanel()
        panel.setScale(1.2)
        panel.zPosition = GamezPosition.resultText + 4
        panel.position = CGPoint(x: width / 2, y: (height / 2) + 15)
        return panel
    }()
    
    lazy var bird: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "yellow-bird-1")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.setScale(1.5)
        node.zPosition = GamezPosition.bird
        node.position = CGPoint(x: (width / 2), y: (height / 2) + 75)
        node.physicsBody = {
            let body = SKPhysicsBody(circleOfRadius: node.height / 2.0)
            body.isDynamic = false
            body.categoryBitMask = PhysicsCatagory.bird
            body.collisionBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
            body.contactTestBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
            return body
        }()
        return node
    }()
    
    let floatUpAndDown = SKAction.sequence([
        SKAction.moveBy(x: 0, y: 35, duration: 1.0),
        SKAction.moveBy(x: 0, y: -35, duration: 1.0)
    ])
    
    func setRandomBirdTextures() {
        let randomOldBird = ["yellow-bird", "red-bird", "blue-bird"].randomElement()!
        let randomNewBird = ["yellow-bird", "red-bird", "blue-bird", "green-bird", "peach-bird", "purple-bird", "kup-bird"].randomElement()!
        for n in 0...2 {
            birdTextures[n] = {
                let texture = SKTexture(imageNamed: "\(newBirds ? randomNewBird : randomOldBird)-\(n + 1)")
                texture.filteringMode = .nearest
                return texture
            }()
        }
        let anim = SKAction.animate(with: [birdTextures[0], birdTextures[1], birdTextures[2], birdTextures[1]], timePerFrame: 0.1)
        bird.run(SKAction.repeatForever(anim))
    }
    
    lazy var ground: SKNode = {
        let node = SKNode()
        node.position = CGPoint(x: 0, y: groundTexture.height)
        node.zPosition = GamezPosition.land
        node.physicsBody = {
            let body = SKPhysicsBody(rectangleOf: CGSize(width: width, height: groundTexture.height * 2.0))
            body.isDynamic = false
            body.categoryBitMask = PhysicsCatagory.land
            return body
        }()
        return node
    }()
    
    public static var settingsButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "settings")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.name = "settings"
        node.setScale(1.2)
        node.position = CGPoint(x: (screenData.shared.width / 2) + 85, y: (screenData.shared.height / 2) - 25)
        return node
    }()
    
    public static var githubButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "github")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.name = "github"
        node.setScale(1.2)
        node.position = CGPoint(x: (screenData.shared.width / 2) - 85, y: (screenData.shared.height / 2) - 25)
        return node
    }()
    
    public static var googleSignInButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "google")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.name = "google"
        node.setScale(1.2)
        node.zPosition = 2
        node.position = CGPoint(x: (screenData.shared.width / 2), y: (screenData.shared.height / 2) - 25)
        return node
    }()
    
   lazy var playButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "flappyplay")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.name = "play"
        node.setScale(1.2)
        node.position = CGPoint(x: (width / 2) - 80, y: (height / 2) - 115)
        return node
    }()
    
    lazy var leaderboardButton: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "board")
        texture.filteringMode = .nearest
        let node = SKSpriteNode(texture: texture)
        node.name = "board"
        node.zPosition = 2
        node.setScale(1.2)
        node.position = CGPoint(x: (width / 2) + 80, y: (height / 2) - 115)
        return node
     }()

    func setGravityAndPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -12.0)
        physicsWorld.contactDelegate = self
    }
    
    func setGroundMoving() {
        let groundWidth = groundTexture.width * 2.0
        let moveGroundSprite = SKAction.moveBy(x: -groundWidth, y: 0, duration: TimeInterval(0.005 * groundWidth))
        let resetGroundSprite = SKAction.moveBy(x: groundWidth, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        for i in 0..<3 + Int(width / groundWidth) {
            let node: SKSpriteNode = {
                let node = SKSpriteNode(texture: groundTexture)
                node.setScale(2.0)
                node.position = CGPoint(x: CGFloat(i) * (node.width - 1), y: node.height / 2.0)
                node.run(moveGroundSpritesForever)
                return node
            }()
            moving.addChild(node)
        }
    }
    
    func setRandomSkyTexture() {
        let rand = Float.random(in: 0 ..< 1)
        var skyTexture = rand < 0.5 ? SKTexture(imageNamed: "night-sky") : SKTexture(imageNamed: "day-sky")
        
        if #available(iOS 12.0, *) {
            if(adaptiveBackground && self.view?.traitCollection.userInterfaceStyle == .dark){
                skyTexture = SKTexture(imageNamed:"night-sky")
            } else if(adaptiveBackground && self.view?.traitCollection.userInterfaceStyle == .light){
                skyTexture = SKTexture(imageNamed:"day-sky")
            }
        }
        
        let skyWidth = skyTexture.width * 1.5
        let moveSkySprite = SKAction.moveBy(x: -skyWidth, y: 0, duration: TimeInterval(0.1 * skyWidth))
        let resetSkySprite = SKAction.moveBy(x: skyWidth, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        for i in 0..<2 + Int(width / skyWidth) {
            let spriteNode: SKSpriteNode = {
                let node = SKSpriteNode(texture: skyTexture)
                node.setScale(1.5)
                node.zPosition = GamezPosition.sky
                node.position = CGPoint(x: CGFloat(i) * (node.width - 1), y: node.height / 3.5 + groundTexture.height * 2.0)
                node.run(moveSkySpritesForever)
                return node
            }()
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
    
    var hasRan = false
    
    var pipeUp: SKSpriteNode = SKSpriteNode()
    var pipeDown: SKSpriteNode = SKSpriteNode()
    
    private func spawnPipes() {
        let height = UInt32(self.height / 4)
        let y = CGFloat(arc4random_uniform(height) + height)

        pipeDown = {
            let node = SKSpriteNode(texture: pipeTextureDown)
            node.setScale(2.0)
            node.position = CGPoint(x: 0.0, y: y + node.height + verticalPipeGap)
            node.physicsBody = {
                let body = SKPhysicsBody(rectangleOf: node.size)
                body.isDynamic = false
                body.categoryBitMask = PhysicsCatagory.pipe
                body.contactTestBitMask = PhysicsCatagory.bird
                return body
            }()
            return node
        }()

        pipeUp = {
            let node = SKSpriteNode(texture: pipeTextureUp)
            node.setScale(2.0)
            node.position = CGPoint(x: 0.0, y: y)
            node.physicsBody = {
                let body = SKPhysicsBody(rectangleOf: node.size)
                body.isDynamic = false
                body.categoryBitMask = PhysicsCatagory.pipe
                body.contactTestBitMask = PhysicsCatagory.bird
                return body
            }()
            return node
        }()

        let contactNode: SKNode = {
            let node = SKNode()
            node.position = CGPoint(x: pipeDown.width - 60 + bird.width / 2, y: self.height / 2)
            let size = CGSize(width: pipeUp.width, height: self.height)
            node.physicsBody = {
                let body = SKPhysicsBody(rectangleOf: size)
                body.isDynamic = false
                body.categoryBitMask = PhysicsCatagory.score
                body.contactTestBitMask = PhysicsCatagory.bird
                return body
            }()
            return node
        }()
        
        // the pipes move actions
        let distanceToMove = (width + 2.0 * pipeTextureUp.width) + 25
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.005 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        let movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        let node: SKNode = {
            let node = SKNode()
            node.position = CGPoint(x: width + pipeTextureUp.width * 2, y: 0)
            node.zPosition = GamezPosition.pipe
            node.addChild(pipeDown)
            node.addChild(pipeUp)
            node.addChild(contactNode)
            node.run(movePipesAndRemove)
            return node
        }()
        pipes.addChild(node)
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
        
        if UserDefaults.standard.object(forKey: "haptics") == nil {
            UserDefaults.standard.set(true, forKey: "haptics")
        }
        haptics = UserDefaults.standard.bool(forKey: "haptics")
        if haptics {
            settingsNode.hapticsToggle.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.hapticsToggleY)
        } else {
            settingsNode.hapticsToggle.position = CGPoint(x: SettingsPositions.toggleOffX, y: SettingsPositions.hapticsToggleY)
        }
        
        if UserDefaults.standard.object(forKey: "adaptiveBackground") == nil {
            UserDefaults.standard.set(false, forKey: "adaptiveBackground")
        }
        adaptiveBackground = UserDefaults.standard.bool(forKey: "adaptiveBackground")
        if adaptiveBackground {
            settingsNode.adaptiveBackgroundToggle.position = CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.adaptiveBackgroundToggleY)
        } else {
            settingsNode.adaptiveBackgroundToggle.position = CGPoint(x: SettingsPositions.toggleOffX, y: SettingsPositions.adaptiveBackgroundToggleY)
        }
        screenData.shared.height = height
        screenData.shared.width = width
        setGravityAndPhysics()
        setGroundMoving()
        setRandomSkyTexture()
        setRandomBirdTextures()
        spawnPipesForever()
        
        addChild(flappybird)
        addChild(moving)
        moving.addChild(pipes)
        addChild(bird)
        addChild(ground)
        addChild(GameScene.githubButton)
        addChild(GameScene.settingsButton)
        addChild(GameScene.googleSignInButton)
        addChild(playButton)
        addChild(leaderboardButton)
        
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
        
        if touchedNodeName == "play" && !GameScene.hitButton {
            GameScene.hitButton = true
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { self.playButton.setScale(1.15) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run{if(self.haptics) {self.impact.impactOccurred()}},
                SKAction.run { self.playButton.setScale(1.2) },
                SKAction.run{self.flashScreen(color: UIColor.black, fadeInDuration: 0.25, peakAlpha: 1.0, fadeOutDuration: 0.25)},
                SKAction.wait(forDuration: 0.25)
            ]),
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
                    GameScene.settingsButton.removeFromParent()
                    GameScene.githubButton.removeFromParent()
                    GameScene.googleSignInButton.removeFromParent()
                    self.playButton.removeFromParent()
                    self.leaderboardButton.removeFromParent()
                    GameScene.hitButton = false
                    self.firstTouch = true
            }
            )
        } else if touchedNodeName == "settings" && !GameScene.hitButton {
            GameScene.hitButton = true
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { GameScene.settingsButton.setScale(1.15) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run{if(self.haptics) {self.impact.impactOccurred()}},
                SKAction.run { GameScene.settingsButton.setScale(1.2) },
                SKAction.wait(forDuration: 0.1)]),
                completion: {
                    self.scaleTwice(node: GameScene.settingsButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    self.scaleTwice(node: self.playButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    self.scaleTwice(node: self.leaderboardButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    if self.afterGameOver {
                        self.scaleTwice(node: self.resultNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    } else {
                        self.scaleTwice(node: self.bird, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                        self.scaleTwice(node: GameScene.githubButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                        self.scaleTwice(node: GameScene.googleSignInButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    }
                    
                    self.settingsNode.setScale(0)
                    self.addChild(self.settingsNode)
                    self.scaleTwice(node: self.settingsNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    
                    self.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.run{GameScene.hitButton = false}]))
            })
        } else if touchedNodeName == "toggleSounds" {
            if(haptics){
                impact.impactOccurred()
            }
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
            if(haptics){
                impact.impactOccurred()
            }
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
        } else if touchedNodeName == "toggleHaptics" {
            playSound(sound: swooshAction)
            if haptics {
                settingsNode.hapticsToggle.run(SKAction.sequence([
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOffX + 6, y: SettingsPositions.hapticsToggleY), duration: 0.08),
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOffX, y: SettingsPositions.hapticsToggleY), duration: 0.12)
                ]))
                
                haptics = false
                UserDefaults.standard.set(false, forKey: "haptics")
                UserDefaults.standard.synchronize()
            } else {
                settingsNode.hapticsToggle.run(SKAction.sequence([
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOnX - 6, y: SettingsPositions.hapticsToggleY), duration: 0.08),
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.hapticsToggleY), duration: 0.12)
                ]))
                
                haptics = true
                UserDefaults.standard.set(true, forKey: "haptics")
                UserDefaults.standard.synchronize()
                impact.impactOccurred()
            }
        } else if touchedNodeName == "toggleAdaptiveBackground" {
            playSound(sound: swooshAction)
            if(haptics){
                impact.impactOccurred()
            }
            if adaptiveBackground {
                settingsNode.adaptiveBackgroundToggle.run(SKAction.sequence([
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOffX + 6, y: SettingsPositions.adaptiveBackgroundToggleY), duration: 0.08),
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOffX, y: SettingsPositions.adaptiveBackgroundToggleY), duration: 0.12)
                ]))
                
                adaptiveBackground = false
                UserDefaults.standard.set(false, forKey: "adaptiveBackground")
                UserDefaults.standard.synchronize()
            } else {
                settingsNode.adaptiveBackgroundToggle.run(SKAction.sequence([
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOnX - 6, y: SettingsPositions.adaptiveBackgroundToggleY), duration: 0.08),
                    SKAction.move(to: CGPoint(x: SettingsPositions.toggleOnX, y: SettingsPositions.adaptiveBackgroundToggleY), duration: 0.12)
                ]))
                
                adaptiveBackground = true
                UserDefaults.standard.set(true, forKey: "adaptiveBackground")
                UserDefaults.standard.synchronize()
            }
        } else if touchedNodeName == "settingsBack" {
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { self.settingsNode.backButton.setScale(0.8) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run{if(self.haptics) {self.impact.impactOccurred()}},
                SKAction.run { self.settingsNode.backButton.setScale(1.0) },
                SKAction.wait(forDuration: 0.1)]),
                completion: {
                    self.scaleTwice(node: self.settingsNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 0.0, secondScaleDuration: 0.1)
                    self.settingsNode.removeFromParent()
                    self.scaleTwice(node: GameScene.settingsButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.25, secondScaleDuration: 0.1)
                    self.scaleTwice(node: self.leaderboardButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    self.scaleTwice(node: self.playButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    
                    if self.afterGameOver {
                        self.scaleTwice(node: self.resultNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    } else {
                        self.scaleTwice(node: self.bird, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.5, secondScaleDuration: 0.1)
                        self.scaleTwice(node: GameScene.githubButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                        self.scaleTwice(node: GameScene.googleSignInButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
                    }
            }
            )
        } else if touchedNodeName == "github" && !GameScene.hitButton {
            GameScene.hitButton = true
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { GameScene.githubButton.setScale(1.15) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run{if(self.haptics) {self.impact.impactOccurred()}},
                SKAction.run { GameScene.githubButton.setScale(1.2) },
                SKAction.wait(forDuration: 0.9)]),
                completion: {
                    guard let url = URL(string: "https://www.github.com/elihwyma/flappybird") else { return }
                    UIApplication.shared.open(url)
                    GameScene.hitButton = false
            }
            )
        } else if touchedNodeName == "google" && !GameScene.hitButton {
            GameScene.hitButton = true
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { GameScene.googleSignInButton.setScale(1.15) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run{if(self.haptics) {self.impact.impactOccurred()}},
                SKAction.run { GameScene.googleSignInButton.setScale(1.2) },
                SKAction.wait(forDuration: 0.9)]),
                completion: {
                    let alert = UIAlertController(title: "Notice", message: "The open source version of Flappy Bird does not have Google SignIn", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
                    })
                    alert.addAction(ok)
                    DispatchQueue.main.async(execute: {
                        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    })
                    GameScene.hitButton = false
            }
            )
        } else if touchedNodeName == "board" && !GameScene.hitButton {
            GameScene.hitButton = true
            run(SKAction.sequence([
                SKAction.run { self.playSound(sound: self.swooshAction) },
                SKAction.run { self.leaderboardButton.setScale(1.15) },
                SKAction.wait(forDuration: 0.1),
                SKAction.run{if(self.haptics) {self.impact.impactOccurred()}},
                SKAction.run { self.leaderboardButton.setScale(1.2) },
                SKAction.wait(forDuration: 0.9)]),
                completion: {
                    let alert = UIAlertController(title: "Notice", message: "The open source version of Flappy Bird does not have leaderboards", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
                    })
                    alert.addAction(ok)
                    DispatchQueue.main.async(execute: {
                        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    })
                    GameScene.hitButton = false
            })
        } else if firstTouch {
            bird.removeAction(forKey: "float")
            taptap.run(SKAction.sequence([
                SKAction.scale(to: 0.0, duration: 0.1),
                SKAction.removeFromParent(),
                SKAction.scale(to: 1.5, duration: 0.0)
            ]))
            
            getReady.run(SKAction.sequence([
                SKAction.scale(to: 0.0, duration: 0.1),
                SKAction.removeFromParent(),
                SKAction.scale(to: 1.2, duration: 0.0)
            ]))
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
        
        let birdRotation = bird.physicsBody!.velocity.dy * (bird.physicsBody!.velocity.dy < 0.4 ? 0.003 : 0.001)
        bird.run(SKAction.rotate(toAngle: min(max(-1.57, birdRotation), 0.6), duration: 0.08))
        if birdRotation < -0.7 {
            bird.speed = 2
        } else {
            bird.speed = 1
        }
    }
    
    @objc private func touchAction() {
        if moving.speed > 0 {
            if(!(bird.position.y >= (self.frame.height + 20))){
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 22))
            }
        }
    }
    
    func gameOver() {
        gameOverDisplayed = true
        playFlapSound = false
        if(haptics){
            notification.notificationOccurred(.error)
        }
        flashScreen(color: UIColor.white, fadeInDuration: 0.1, peakAlpha: 0.9, fadeOutDuration: 0.25)
        
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.collisionBitMask = PhysicsCatagory.land
        bird.physicsBody?.isDynamic = true
        
        let anim = SKAction.animate(with: [birdTextures[0], birdTextures[1], birdTextures[2], birdTextures[1]], timePerFrame: 0.1)
        bird.run(SKAction.repeatForever(anim))
        
        playSound(sound: hitAction)
        run(SKAction.wait(forDuration: TimeInterval(UInt32(0.2))))
        playSound(sound: dieAction)
        
        gameover.setScale(0)
        addChild(gameover)
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run{self.scoreLabelNode.removeFromParent()},
            SKAction.run{self.scoreLabelNodeInside.removeFromParent()},
            SKAction.run{self.scaleTwice(node: self.gameover, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.25, secondScaleDuration: 0.1)},
        ]))
        moving.speed = 0
    }
    
    func addResultsAndButtons() {
        if canShowScore{
            resultNode.setScale(0)
            resultNode.score = score
            addChild(resultNode)
            scaleTwice(node: resultNode, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.25, secondScaleDuration: 0.1)
            
            GameScene.settingsButton.position = CGPoint(x: (screenData.shared.width / 2), y: (screenData.shared.height / 2) - 25)
            GameScene.settingsButton.setScale(0)
            addChild(GameScene.settingsButton)
            scaleTwice(node: GameScene.settingsButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
            
            playButton.setScale(0)
            addChild(playButton)
            scaleTwice(node: playButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
            
            leaderboardButton.setScale(0)
            addChild(leaderboardButton)
            scaleTwice(node: leaderboardButton, firstScale: 1.0, firstScaleDuration: 0.1, secondScale: 1.2, secondScaleDuration: 0.1)
            
            afterGameOver = true
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
        scoreLabelNode.run(SKAction.scale(to: 1.0, duration: 0.0))
        scoreLabelNodeInside.run(SKAction.scale(to: 1.0, duration: 0.0))
        
        gameOverDisplayed = false
        hitGround = false
        pipes.setScale(0)
        score = 0
        moving.speed = 1
        bird.speed = 1
        bird.zRotation = 0.0
        bird.position = CGPoint(x: width / 2.5, y: height / 2)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.collisionBitMask = PhysicsCatagory.land | PhysicsCatagory.pipe
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
    
    func flashScreen(color: UIColor, fadeInDuration: TimeInterval, peakAlpha: CGFloat, fadeOutDuration: TimeInterval){
        let flash = SKShapeNode(rect: CGRect(x: -5, y: -5, width: width + 10 ,height: height + 10))
        flash.zPosition = 7
        flash.fillColor = color
        flash.alpha = 0.0
        self.addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: peakAlpha, duration: fadeInDuration),
            SKAction.fadeAlpha(to: 0.0, duration: fadeOutDuration),
            SKAction.removeFromParent()
        ]))
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if (bird.speed == 1 || bird.speed == 2) && !gameOverDisplayed && ((contact.bodyA.categoryBitMask & PhysicsCatagory.score) == PhysicsCatagory.score || (contact.bodyB.categoryBitMask & PhysicsCatagory.score) == PhysicsCatagory.score) {
            score += 1
            
            if(haptics){
                impact.impactOccurred()
            }
            self.playSound(sound: self.pointAction)
            
            scaleTwice(node: scoreLabelNode, firstScale: 1.5, firstScaleDuration: 0.1, secondScale: 1.0, secondScaleDuration: 0.1)
            scaleTwice(node: scoreLabelNodeInside, firstScale: 1.5, firstScaleDuration: 0.1, secondScale: 1.0, secondScaleDuration: 0.1)
        } else if !gameOverDisplayed && ((contact.bodyA.categoryBitMask & PhysicsCatagory.pipe) == PhysicsCatagory.pipe || (contact.bodyB.categoryBitMask & PhysicsCatagory.pipe) == PhysicsCatagory.pipe) {
            gameOver()
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
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
