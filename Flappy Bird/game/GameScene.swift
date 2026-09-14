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

// MARK: - Extensions

extension SKTexture {
    var width: CGFloat {
        size().width
    }

    var height: CGFloat {
        size().height
    }
}

extension SKNode {
    var width: CGFloat {
        frame.width
    }

    var height: CGFloat {
        frame.height
    }
}

// MARK: - Physics

struct PhysicsCategory {
    static let bird: UInt32 = 1 << 0
    static let land: UInt32 = 1 << 1
    static let pipe: UInt32 = 1 << 2
    static let score: UInt32 = 1 << 3
}

// Keep the original name available if other project files use it.
typealias PhysicsCatagory = PhysicsCategory

// MARK: - Z Positions

struct GameZPosition {
    static let sky: CGFloat = -3
    static let pipe: CGFloat = -2
    static let bird: CGFloat = -1
    static let land: CGFloat = 0
    static let score: CGFloat = 1
    static let result: CGFloat = 2
    static let resultText: CGFloat = 3
}

// Keep the original name available if other project files use it.
typealias GamezPosition = GameZPosition

// MARK: - Global Game Data

public final class ScreenData {
    static let shared = ScreenData()

    var height: CGFloat = 0
    var width: CGFloat = 0

    private init() {}
}


// Keep compatibility with existing project code.
typealias screenData = ScreenData

var canShowScore = true
var timeTook: Double = 0
var rosesCounter = 0
var hasRanFor1time = false

// MARK: - Game Scene

final class GameScene: SKScene {

    // MARK: Constants

    private enum Constants {
        static let superScore = 1000

        static let gravity = CGVector(dx: 0, dy: -12)

        static let verticalPipeGap: CGFloat = 130
        static let pipeScale: CGFloat = 2
        static let birdScale: CGFloat = 1.5

        static let idleFloatDistance: CGFloat = 35
        static let idleFloatDuration: TimeInterval = 1

        static let flapImpulse: CGFloat = 22
        static let flapRotation: CGFloat = 0.45
        static let flapRotationHold: TimeInterval = 0.60

        static let minimumBirdYOffset: CGFloat = 20

        static let groundMoveSpeed: TimeInterval = 0.005
        static let skyMoveSpeed: TimeInterval = 0.1
        static let pipeMoveSpeed: TimeInterval = 0.005

        static let animationFrameDuration: TimeInterval = 0.1

        static let uiAnimationDuration: TimeInterval = 0.1
        static let toggleAnimationDuration: TimeInterval = 0.12

        static let pauseButtonScale: CGFloat = 2.4
        static let pauseButtonInset: CGFloat = 45

        static let gameOverDelay: TimeInterval = 0.8
        static let resultDelay: TimeInterval = 0.2
    }
    
    private struct SeededRandomNumberGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            self.state = seed
        }

        mutating func next() -> UInt64 {
            // SplitMix64
            state &+= 0x9E3779B97F4A7C15

            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }

        mutating func nextInt(in range: ClosedRange<Int>) -> Int {
            let span = UInt64(range.upperBound - range.lowerBound + 1)
            return range.lowerBound + Int(next() % span)
        }
    }

    // MARK: Shared State

    static let shared = GameScene()
    
    // MARK: Pipe seed
    private var pipeSeed: UInt64 = 123456789
    private var pipeRandom = SeededRandomNumberGenerator(seed: UInt64(arc4random()))

    static var width: CGFloat {
        shared.width
    }

    static var height: CGFloat {
        shared.height
    }

    // These remain static because other project files may reference them.
    static let settingsButtonTexture =
        Assets.shared.sprites.textureNamed("settings")

    static let githubButtonTexture =
        Assets.shared.sprites.textureNamed("github")
    
    static let smallPlayButtonTexture =
        Assets.shared.sprites.textureNamed("smallresume")
    
    static let smallPauseButtonTexture =
        Assets.shared.sprites.textureNamed("smallpause")
    

    static var hitButton = true

    // MARK: Game State

    private var score = 0 {
        didSet {
            scoreLabelNode.text = String(score)
            scoreLabelNodeInside.text = String(score)
        }
    }

    private var gameStartTime: TimeInterval = 0
    private var lastFlapTime: TimeInterval = 0

    private var isWaitingToStart = false
    private var isGameOver = false
    private var hasHitGround = false
    private var isShowingGameOver = false

    private var playFlapSound = false

    private var playSounds = true
    private var newBirds = true
    private var haptics = true
    private var adaptiveBackground = false

    private var skyNodes = [SKSpriteNode]()
    private var birdTextures = [SKTexture(), SKTexture(), SKTexture()]

    // MARK: Feedback

    private let impactFeedback = UIImpactFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    // MARK: Sounds

    private let flapSound = SKAction.playSoundFileNamed(
        "sounds/sfx_wing.caf",
        waitForCompletion: false
    )

    private let dieSound = SKAction.playSoundFileNamed(
        "sounds/sfx_die.caf",
        waitForCompletion: false
    )

    private let pointSound = SKAction.playSoundFileNamed(
        "sounds/sfx_point.wav",
        waitForCompletion: false
    )

    private let hitSound = SKAction.playSoundFileNamed(
        "sounds/sfx_hit.caf",
        waitForCompletion: false
    )

    private let swooshSound = SKAction.playSoundFileNamed(
        "sounds/sfx_swooshing.caf",
        waitForCompletion: false
    )

    // MARK: Textures

    private let pipeTextureUp =
        Assets.shared.sprites.textureNamed("PipeUp")

    private let pipeTextureDown =
        Assets.shared.sprites.textureNamed("PipeDown")

    private let groundTexture =
        Assets.shared.sprites.textureNamed("land")

    private let gameOverTexture =
        Assets.shared.sprites.textureNamed("gameover")

    private let flappyBirdTexture =
        Assets.shared.sprites.textureNamed("flappybird")

    private let getReadyTexture =
        Assets.shared.sprites.textureNamed("get-ready")

    private let tapTapTexture =
        Assets.shared.sprites.textureNamed("taptap")

    private let defaultBirdTexture =
        Assets.shared.sprites.textureNamed("yellow-bird-1")

    private let playButtonTexture =
        Assets.shared.sprites.textureNamed("flappyplay")

    private let dayTexture =
        Assets.shared.sprites.textureNamed("day-sky")

    private let nightTexture =
        Assets.shared.sprites.textureNamed("night-sky")

    // MARK: Scene Nodes

    private let moving = SKNode()
    private let pipes = SKNode()

    private lazy var bird = makeBird()
    private lazy var ground = makeGround()

    private lazy var flappyBird = makeFlappyBird()
    private lazy var getReady = makeGetReady()
    private lazy var tapTap = makeTapTap()

    private lazy var gameOverNode = makeGameOverNode()
    private lazy var resultNode = makeResultNode()
    private lazy var settingsNode = makeSettingsNode()

    private lazy var playButton = makePlayButton()
    private lazy var pauseButton = makePauseButton()
    private lazy var resumeButton = makeResumeButton()
    private lazy var pauseOverlay = makePauseOverlay()

    private var isPausedByUser = false

    private lazy var scoreLabelNode = SKLabelNode(
        fontNamed: "04b_19"
    ).then {
        $0.fontColor = .black
        $0.fontSize = 50
        $0.position = CGPoint(
            x: width / 2,
            y: 3 * height / 4
        )
        $0.zPosition = GameZPosition.score + 1
    }

    private lazy var scoreLabelNodeInside = SKLabelNode(
        fontNamed: "inside"
    ).then {
        $0.fontColor = .white
        $0.fontSize = 50
        $0.position = CGPoint(
            x: width / 2 - 1.5,
            y: 3 * height / 4
        )
        $0.zPosition = GameZPosition.score
    }

    // MARK: Static Buttons

    private static var settingsButton =
        SKSpriteNode(
            texture: settingsButtonTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.name = "settings"
            $0.setScale(1.2)
            $0.position = CGPoint(
                x: ScreenData.shared.width / 2 + 45,
                y: ScreenData.shared.height / 2 - 25
            )
        }

    private static var githubButton =
        SKSpriteNode(
            texture: githubButtonTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.name = "github"
            $0.setScale(1.2)
            $0.position = CGPoint(
                x: ScreenData.shared.width / 2 - 45,
                y: ScreenData.shared.height / 2 - 25
            )
        }

    // MARK: Idle Animation

    private lazy var idleAnimation: SKAction = {
        let floatUp = SKAction.moveBy(
            x: 0,
            y: Constants.idleFloatDistance,
            duration: Constants.idleFloatDuration
        )

        let floatDown = SKAction.moveBy(
            x: 0,
            y: -Constants.idleFloatDistance,
            duration: Constants.idleFloatDuration
        )

        return SKAction.repeatForever(
            SKAction.sequence([
                floatUp,
                floatDown
            ])
        )
    }()

    // MARK: Scene Setup

    override func didMove(to view: SKView) {
        configureSettings()
        configureScene()
        configurePhysics()
        configureWorld()

        startIdleAnimation()
    }

    private func configureScene() {
        ScreenData.shared.height = height
        ScreenData.shared.width = width

        addChild(flappyBird)
        addChild(moving)

        moving.addChild(pipes)

        addChild(bird)
        addChild(ground)

        addChild(Self.githubButton)
        addChild(Self.settingsButton)
        addChild(playButton)
        pauseButton.removeFromParent()
        resumeButton.removeFromParent()

        score = 0

        moving.speed = 1
        bird.speed = 1

        pipes.setScale(0)
    }

    private func configurePhysics() {
        physicsWorld.gravity = Constants.gravity
        physicsWorld.contactDelegate = self
    }

    private func configureWorld() {
        createGroundMovement()
        updateSky()
        updateBirdTextures()
        startPipeSpawner()
    }

    // MARK: Settings

    private func configureSettings() {
        playSounds = loadBoolSetting(
            key: "playSounds",
            defaultValue: true
        )

        newBirds = loadBoolSetting(
            key: "newBirds",
            defaultValue: true
        )

        haptics = loadBoolSetting(
            key: "haptics",
            defaultValue: true
        )

        adaptiveBackground = loadBoolSetting(
            key: "adaptiveBackground",
            defaultValue: false
        )

        updateSettingsUI()
    }

    private func loadBoolSetting(
        key: String,
        defaultValue: Bool
    ) -> Bool {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: key) == nil {
            defaults.set(defaultValue, forKey: key)
        }

        return defaults.bool(forKey: key)
    }

    private func saveSetting(
        _ value: Bool,
        key: String
    ) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private func updateSettingsUI() {
        settingsNode.soundToggle.position = CGPoint(
            x: playSounds
                ? SettingsPositions.toggleOnX
                : SettingsPositions.toggleOffX,
            y: SettingsPositions.soundToggleY
        )

        settingsNode.newBirdsToggle.position = CGPoint(
            x: newBirds
                ? SettingsPositions.toggleOnX
                : SettingsPositions.toggleOffX,
            y: SettingsPositions.newBirdsToggleY
        )

        settingsNode.hapticsToggle.position = CGPoint(
            x: haptics
                ? SettingsPositions.toggleOnX
                : SettingsPositions.toggleOffX,
            y: SettingsPositions.hapticsToggleY
        )

        settingsNode.adaptiveBackgroundToggle.position = CGPoint(
            x: adaptiveBackground
                ? SettingsPositions.toggleOnX
                : SettingsPositions.toggleOffX,
            y: SettingsPositions.adaptiveBackgroundToggleY
        )
    }

    // MARK: Node Creation

    private func makeBird() -> SKSpriteNode {
        SKSpriteNode(
            texture: defaultBirdTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.setScale(Constants.birdScale)
            $0.zPosition = GameZPosition.bird
            $0.position = CGPoint(
                x: width / 2,
                y: height / 2 + 75
            )

            $0.physicsBody = SKPhysicsBody(
                circleOfRadius: $0.height / 2
            ).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCategory.bird
                $0.collisionBitMask =
                    PhysicsCategory.land |
                    PhysicsCategory.pipe
                $0.contactTestBitMask =
                    PhysicsCategory.land |
                    PhysicsCategory.pipe
            }
        }
    }

    private func makeGround() -> SKNode {
        SKNode().then {
            $0.position = CGPoint(
                x: 0,
                y: groundTexture.height
            )

            $0.zPosition = GameZPosition.land

            $0.physicsBody = SKPhysicsBody(
                rectangleOf: CGSize(
                    width: width,
                    height: groundTexture.height * 2
                )
            ).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCategory.land
            }
        }
    }

    private func makeFlappyBird() -> SKSpriteNode {
        SKSpriteNode(
            texture: flappyBirdTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.setScale(1.5)
            $0.position = CGPoint(
                x: width / 2,
                y: height / 2 + 200
            )
        }
    }

    private func makeGetReady() -> SKSpriteNode {
        SKSpriteNode(
            texture: getReadyTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.setScale(1.2)
            $0.position = CGPoint(
                x: width / 2,
                y: height / 2 + 130
            )
        }
    }

    private func makeTapTap() -> SKSpriteNode {
        SKSpriteNode(
            texture: tapTapTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.setScale(1.5)
            $0.position = CGPoint(
                x: width / 2,
                y: height / 2
            )
        }
    }

    private func makeGameOverNode() -> SKSpriteNode {
        SKSpriteNode(
            texture: gameOverTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.setScale(1.5)
            $0.zPosition = GameZPosition.score
            $0.position = CGPoint(
                x: width / 2,
                y: height / 2 + 210
            )
        }
    }

    private func makeResultNode() -> ResultBoard {
        ResultBoard(score: score).then {
            $0.zPosition = GameZPosition.result
            $0.position = CGPoint(
                x: width / 2,
                y: height / 2 + 75
            )
        }
    }

    private func makeSettingsNode() -> SettingsPanel {
        SettingsPanel().then {
            $0.setScale(1.2)
            $0.zPosition = GameZPosition.resultText + 4
            $0.position = CGPoint(
                x: width / 2,
                y: height / 2 + 15
            )
        }
    }

    private func makePlayButton() -> SKSpriteNode {
        SKSpriteNode(
            texture: playButtonTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.name = "play"
            $0.setScale(1.2)
            $0.position = CGPoint(
                x: width / 2,
                y: height / 2 - 115
            )
        }
    }
    
    private func pauseButtonPosition() -> CGPoint {
        guard let view = self.view else {
            return CGPoint(
                x: 32,
                y: height - 32
            )
        }

        let safeInsets = view.safeAreaInsets

        // Top-left corner of the device's safe area, in SKView coordinates.
        let topLeftInView = CGPoint(
            x: view.bounds.minX + safeInsets.left,
            y: view.bounds.minY + safeInsets.top
        )

        // Convert the actual visible top-left into scene coordinates.
        let topLeftInScene = convertPoint(fromView: topLeftInView)

        // The button's position is its center.
        let buttonHalfWidth =
            Self.smallPauseButtonTexture.size().width *
            Constants.pauseButtonScale / 2

        let buttonHalfHeight =
            Self.smallPauseButtonTexture.size().height *
            Constants.pauseButtonScale / 2

        let margin: CGFloat = 12

        return CGPoint(
            x: topLeftInScene.x + buttonHalfWidth + margin,
            y: topLeftInScene.y - buttonHalfHeight - margin
        )
    }

    private func makePauseButton() -> SKSpriteNode {
        SKSpriteNode(
            texture: Self.smallPauseButtonTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.name = "pause"
            $0.setScale(Constants.pauseButtonScale)
            $0.position = pauseButtonPosition()
            $0.zPosition = 100
        }
    }

    private func makeResumeButton() -> SKSpriteNode {
        SKSpriteNode(
            texture: Self.smallPlayButtonTexture.then {
                $0.filteringMode = .nearest
            }
        ).then {
            $0.name = "resume"
            $0.setScale(Constants.pauseButtonScale)
            $0.position = pauseButtonPosition()
            $0.zPosition = 100
        }
    }

    private func makePauseOverlay() -> SKShapeNode {
        SKShapeNode(
            rect: CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )
        ).then {
            $0.name = "pauseOverlay"
            $0.fillColor = .black
            $0.strokeColor = .clear
            $0.alpha = 0.55
            $0.zPosition = GameZPosition.resultText + 4
        }
    }

    // MARK: Bird

    private func updateBirdTextures() {
        let randomValue = Float.random(in: 0..<1)

        for index in 0...2 {
            let color: String

            if newBirds {
                switch randomValue {
                case ..<0.161:
                    color = "yellow"
                case ..<0.322:
                    color = "red"
                case ..<0.483:
                    color = "blue"
                case ..<0.644:
                    color = "green"
                case ..<0.805:
                    color = "peach"
                case ..<0.97:
                    color = "purple"
                default:
                    color = "kup"
                }
            } else {
                switch randomValue {
                case ..<0.33:
                    color = "yellow"
                case ..<0.66:
                    color = "red"
                default:
                    color = "blue"
                }
            }

            birdTextures[index] =
                Assets.shared.sprites.textureNamed(
                    "\(color)-bird-\(index + 1)"
                ).then {
                    $0.filteringMode = .nearest
                }
        }

        applyBirdAnimation()
    }

    private func applyBirdAnimation() {
        let animation = SKAction.animate(
            with: [
                birdTextures[0],
                birdTextures[1],
                birdTextures[2],
                birdTextures[1]
            ],
            timePerFrame: Constants.animationFrameDuration
        )

        bird.removeAction(forKey: "birdAnimation")

        bird.run(
            SKAction.repeatForever(animation),
            withKey: "birdAnimation"
        )
    }

    private func startIdleAnimation() {
        bird.removeAction(forKey: "idle")

        bird.run(
            idleAnimation,
            withKey: "idle"
        )
    }

    private func stopIdleAnimation() {
        bird.removeAction(forKey: "idle")
    }

    private func flapBird() {
        guard moving.speed > 0 else {
            return
        }

        guard bird.physicsBody?.isDynamic == true else {
            return
        }

        guard bird.position.y < height + Constants.minimumBirdYOffset else {
            return
        }

        lastFlapTime = CFAbsoluteTimeGetCurrent()

        bird.zRotation = Constants.flapRotation

        bird.physicsBody?.velocity = CGVector(
            dx: 0,
            dy: 0
        )

        bird.physicsBody?.applyImpulse(
            CGVector(
                dx: 0,
                dy: Constants.flapImpulse
            )
        )

        if playSounds {
            run(flapSound)
        }
    }

    private func updateBirdRotation() {
        guard let physicsBody = bird.physicsBody,
              physicsBody.isDynamic else {
            return
        }

        let timeSinceFlap =
            CFAbsoluteTimeGetCurrent() - lastFlapTime

        if timeSinceFlap < Constants.flapRotationHold {
            bird.zRotation = Constants.flapRotation
            return
        }

        let velocityY = physicsBody.velocity.dy

        let targetRotation = min(
            max(
                velocityY *
                    (velocityY < 0.4 ? 0.003 : 0.001),
                -1.57
            ),
            0.6
        )

        bird.zRotation +=
            (targetRotation - bird.zRotation) * 0.15

        bird.speed = targetRotation < -0.7 ? 2 : 1
    }

    // MARK: Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard !hasHitGround else {
            return
        }

        updateBirdRotation()
    }

    // MARK: Input

    override func touchesBegan(
        _ touches: Set<UITouch>?,
        with event: UIEvent?
    ) {
        guard let touch = touches?.first else {
            return
        }

        let location = touch.location(in: self)
        let nodeName = atPoint(location).name

        switch nodeName {
        case "play":
            handlePlayTap()
            
        case "pause":
            handlePauseTap()

        case "resume":
            handleResumeTap()

        case "settings":
            handleSettingsTap()

        case "github":
            handleGitHubTap()

        case "toggleSounds":
            handleSoundToggle()

        case "toggleNewBirds":
            handleNewBirdsToggle()

        case "toggleHaptics":
            handleHapticsToggle()

        case "toggleAdaptiveBackground":
            handleAdaptiveBackgroundToggle()

        case "settingsBack":
            handleSettingsBack()

        default:
            handleGameTap()
        }
    }

    public func keyboardFlapp() {
        handleGameTap()
    }

    private func handleGameTap() {
        if isWaitingToStart {
            startGame()
            return
        }

        flapBird()
    }

    private func startGame() {
        guard isWaitingToStart else {
            return
        }

        isWaitingToStart = false
        gameStartTime = CFAbsoluteTimeGetCurrent()

        stopIdleAnimation()

        removeStartUI()

        pauseButton.removeAllActions()
        pauseButton.position = pauseButtonPosition()
        pauseButton.setScale(0)
        addChild(pauseButton)

        pauseButton.run(
            .scale(to: Constants.pauseButtonScale, duration: 0.1)
        )

        pipes.setScale(1)

        bird.physicsBody?.isDynamic = true

        flapBird()
    }

    private func removeStartUI() {
        tapTap.run(
            SKAction.sequence([
                .scale(to: 0, duration: 0.1),
                .removeFromParent(),
                .scale(to: 1.5, duration: 0)
            ])
        )

        getReady.run(
            SKAction.sequence([
                .scale(to: 0, duration: 0.1),
                .removeFromParent(),
                .scale(to: 1.2, duration: 0)
            ])
        )
    }

    // MARK: Play Button

    private func handlePlayTap() {
        guard !Self.hitButton else {
            return
        }

        Self.hitButton = true

        playSound(swooshSound)

        playButton.setScale(1.15)

        run(
            SKAction.sequence([
                .wait(forDuration: 0.1),
                .run { [weak self] in
                    guard let self else { return }

                    if self.haptics {
                        self.impactFeedback.impactOccurred()
                    }
                },
                .run { [weak self] in
                    self?.playButton.setScale(1.2)
                },
                .run { [weak self] in
                    self?.flashScreen(
                        color: .black,
                        fadeInDuration: 0.25,
                        peakAlpha: 1,
                        fadeOutDuration: 0.25
                    )
                },
                .wait(forDuration: 0.25)
            ]),
            completion: { [weak self] in
                self?.prepareNewGame()
            }
        )
    }
    
    private func handlePauseTap() {
        guard !Self.hitButton,
              !isWaitingToStart,
              !isGameOver,
              !isShowingGameOver,
              !isPausedByUser else {
            return
        }

        Self.hitButton = true
        isPausedByUser = true

        playSound(swooshSound)

        if haptics {
            impactFeedback.impactOccurred()
        }

        pauseButton.removeAllActions()
        pauseButton.removeFromParent()

        pauseOverlay.setScale(1)
        pauseOverlay.alpha = 0.55
        addChild(pauseOverlay)

        resumeButton.removeAllActions()
        resumeButton.position = pauseButtonPosition()
        resumeButton.setScale(Constants.pauseButtonScale)
        addChild(resumeButton)

        isPaused = true
    }

    private func handleResumeTap() {
        guard isPausedByUser else {
            return
        }

        isPaused = false
        isPausedByUser = false

        playSound(swooshSound)

        if haptics {
            impactFeedback.impactOccurred()
        }

        resumeButton.removeAllActions()
        resumeButton.removeFromParent()

        pauseOverlay.run(
            .sequence([
                .fadeOut(withDuration: 0.1),
                .removeFromParent()
            ])
        )

        pauseButton.removeAllActions()
        pauseButton.position = pauseButtonPosition()
        pauseButton.setScale(0)
        addChild(pauseButton)

        pauseButton.run(
            .sequence([
                .scale(
                    to: Constants.pauseButtonScale * 0.875,
                    duration: 0.1
                ),
                .scale(
                    to: Constants.pauseButtonScale,
                    duration: 0.1
                )
            ]),
            completion: {
                Self.hitButton = false
            }
        )
    }

    private func prepareNewGame() {
        if isGameOver {
            resetScene()
            updateBirdTextures()
        } else {
            prepareInitialGame()
            updateBirdTextures()
        }

        Self.settingsButton.removeFromParent()
        Self.githubButton.removeFromParent()
        playButton.removeFromParent()

        isWaitingToStart = true
        isGameOver = false
        Self.hitButton = false
    }

    private func prepareInitialGame() {
        bird.removeAction(forKey: "idle")

        addChild(tapTap)
        addChild(getReady)
        addChild(scoreLabelNode)
        addChild(scoreLabelNodeInside)

        bird.position = CGPoint(
            x: width / 2.5,
            y: height / 2
        )

        flappyBird.removeFromParent()

        startIdleAnimation()
    }

    // MARK: Settings UI

    private func handleSettingsTap() {
        guard !Self.hitButton else {
            return
        }

        Self.hitButton = true

        playSound(swooshSound)

        Self.settingsButton.setScale(1.15)

        run(
            SKAction.sequence([
                .wait(forDuration: 0.1),
                .run { [weak self] in
                    guard let self else { return }

                    if self.haptics {
                        self.impactFeedback.impactOccurred()
                    }
                },
                .run {
                    Self.settingsButton.setScale(1.2)
                },
                .wait(forDuration: 0.1)
            ]),
            completion: { [weak self] in
                self?.showSettings()
            }
        )
    }

    private func showSettings() {
        scaleTwice(
            node: Self.settingsButton,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 0,
            secondScaleDuration: 0.1
        )

        scaleTwice(
            node: playButton,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 0,
            secondScaleDuration: 0.1
        )

        if isGameOver {
            scaleTwice(
                node: resultNode,
                firstScale: 1,
                firstScaleDuration: 0.1,
                secondScale: 0,
                secondScaleDuration: 0.1
            )
        } else {
            scaleTwice(
                node: bird,
                firstScale: 1,
                firstScaleDuration: 0.1,
                secondScale: 0,
                secondScaleDuration: 0.1
            )

            scaleTwice(
                node: Self.githubButton,
                firstScale: 1,
                firstScaleDuration: 0.1,
                secondScale: 0,
                secondScaleDuration: 0.1
            )
        }

        settingsNode.setScale(0)
        addChild(settingsNode)

        scaleTwice(
            node: settingsNode,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 1.2,
            secondScaleDuration: 0.1
        )

        unlockButtons()
    }

    private func handleSettingsBack() {
        playSound(swooshSound)

        settingsNode.backButton.setScale(0.8)

        run(
            SKAction.sequence([
                .wait(forDuration: 0.1),
                .run { [weak self] in
                    guard let self else { return }

                    if self.haptics {
                        self.impactFeedback.impactOccurred()
                    }
                },
                .run {
                    self.settingsNode.backButton.setScale(1)
                },
                .wait(forDuration: 0.1)
            ]),
            completion: { [weak self] in
                self?.hideSettings()
            }
        )
    }

    private func hideSettings() {
        scaleTwice(
            node: settingsNode,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 0,
            secondScaleDuration: 0.1
        )

        settingsNode.removeFromParent()

        scaleTwice(
            node: Self.settingsButton,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 1.25,
            secondScaleDuration: 0.1
        )

        scaleTwice(
            node: playButton,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 1.2,
            secondScaleDuration: 0.1
        )

        if isGameOver {
            scaleTwice(
                node: resultNode,
                firstScale: 1,
                firstScaleDuration: 0.1,
                secondScale: 1.2,
                secondScaleDuration: 0.1
            )
        } else {
            scaleTwice(
                node: bird,
                firstScale: 1,
                firstScaleDuration: 0.1,
                secondScale: 1.5,
                secondScaleDuration: 0.1
            )

            scaleTwice(
                node: Self.githubButton,
                firstScale: 1,
                firstScaleDuration: 0.1,
                secondScale: 1.2,
                secondScaleDuration: 0.1
            )
        }
    }

    private func unlockButtons() {
        run(
            .sequence([
                .wait(forDuration: 0.2),
                .run {
                    Self.hitButton = false
                }
            ])
        )
    }

    // MARK: Settings Toggles

    private func toggle(
        value: inout Bool,
        key: String,
        control: SKNode,
        y: CGFloat
    ) {
        value.toggle()

        saveSetting(value, key: key)

        let targetX = value
            ? SettingsPositions.toggleOnX
            : SettingsPositions.toggleOffX

        let overshootX = value
            ? targetX - 6
            : targetX + 6

        control.run(
            .sequence([
                .move(
                    to: CGPoint(
                        x: overshootX,
                        y: y
                    ),
                    duration: 0.08
                ),
                .move(
                    to: CGPoint(
                        x: targetX,
                        y: y
                    ),
                    duration: Constants.toggleAnimationDuration
                )
            ])
        )
    }

    private func handleSoundToggle() {
        if haptics {
            impactFeedback.impactOccurred()
        }

        if !playSounds {
            playSound(swooshSound)
        }

        toggle(
            value: &playSounds,
            key: "playSounds",
            control: settingsNode.soundToggle,
            y: SettingsPositions.soundToggleY
        )
    }

    private func handleNewBirdsToggle() {
        if haptics {
            impactFeedback.impactOccurred()
        }

        playSound(swooshSound)

        toggle(
            value: &newBirds,
            key: "newBirds",
            control: settingsNode.newBirdsToggle,
            y: SettingsPositions.newBirdsToggleY
        )
    }

    private func handleHapticsToggle() {
        playSound(swooshSound)

        toggle(
            value: &haptics,
            key: "haptics",
            control: settingsNode.hapticsToggle,
            y: SettingsPositions.hapticsToggleY
        )

        if haptics {
            impactFeedback.impactOccurred()
        }
    }

    private func handleAdaptiveBackgroundToggle() {
        playSound(swooshSound)

        if haptics {
            impactFeedback.impactOccurred()
        }

        toggle(
            value: &adaptiveBackground,
            key: "adaptiveBackground",
            control: settingsNode.adaptiveBackgroundToggle,
            y: SettingsPositions.adaptiveBackgroundToggleY
        )

        updateSky()
    }

    // MARK: GitHub

    private func handleGitHubTap() {
        guard !Self.hitButton else {
            return
        }

        Self.hitButton = true

        playSound(swooshSound)

        Self.githubButton.setScale(1.15)

        run(
            .sequence([
                .wait(forDuration: 0.1),
                .run { [weak self] in
                    guard let self else { return }

                    if self.haptics {
                        self.impactFeedback.impactOccurred()
                    }
                },
                .run {
                    Self.githubButton.setScale(1.2)
                },
                .wait(forDuration: 0.9)
            ]),
            completion: {
                guard let url = URL(
                    string: "https://www.github.com/crypticplank/flappybird"
                ) else {
                    Self.hitButton = false
                    return
                }

                UIApplication.shared.open(url)

                Self.hitButton = false
            }
        )
    }

    // MARK: Ground

    private func createGroundMovement() {
        let groundWidth = groundTexture.width * 2

        let moveGround = SKAction.moveBy(
            x: -groundWidth,
            y: 0,
            duration: Constants.groundMoveSpeed * groundWidth
        )

        let resetGround = SKAction.moveBy(
            x: groundWidth,
            y: 0,
            duration: 0
        )

        let movement = SKAction.repeatForever(
            .sequence([
                moveGround,
                resetGround
            ])
        )

        let count = 2 + Int(width / groundWidth)

        for index in 0..<count {
            let node = SKSpriteNode(
                texture: groundTexture
            ).then {
                $0.setScale(2)
                $0.position = CGPoint(
                    x: CGFloat(index) * ($0.width - 1),
                    y: $0.height / 2
                )
                $0.run(movement)
            }

            moving.addChild(node)
        }
    }

    // MARK: Sky

    private func updateSky() {
        let randomTexture =
            Float.random(in: 0..<1) < 0.5
            ? nightTexture
            : dayTexture

        var skyTexture = randomTexture

        if #available(iOS 12.0, *) {
            if adaptiveBackground {
                skyTexture =
                    view?.traitCollection.userInterfaceStyle == .dark
                    ? nightTexture
                    : dayTexture
            }
        }

        let skyWidth = skyTexture.width * 1.5

        let moveSky = SKAction.moveBy(
            x: -skyWidth,
            y: 0,
            duration: Constants.skyMoveSpeed * skyWidth
        )

        let resetSky = SKAction.moveBy(
            x: skyWidth,
            y: 0,
            duration: 0
        )

        let movement = SKAction.repeatForever(
            .sequence([
                moveSky,
                resetSky
            ])
        )

        let requiredCount = 2 + Int(width / skyWidth)

        for index in 0..<requiredCount {
            let node = SKSpriteNode(
                texture: skyTexture
            ).then {
                $0.setScale(1.5)
                $0.zPosition = GameZPosition.sky
                $0.position = CGPoint(
                    x: CGFloat(index) * ($0.width - 1),
                    y: $0.height / 3.5 +
                        groundTexture.height * 2
                )
                $0.run(movement)
            }

            if skyNodes.count < requiredCount {
                skyNodes.append(node)
            } else {
                skyNodes[index].removeFromParent()
                skyNodes[index] = node
            }

            moving.addChild(node)
        }
    }

    // MARK: Pipes

    private func startPipeSpawner() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnPipe()
        }

        let delay = SKAction.wait(forDuration: 1)

        run(
            .repeatForever(
                .sequence([
                    spawn,
                    delay
                ])
            ),
            withKey: "pipeSpawner"
        )
    }

    private func spawnPipe() {
        let quarterHeight = Int(height / 4)

        let y = CGFloat(
            pipeRandom.nextInt(
                in: quarterHeight...(quarterHeight * 2)
            )
        )

        let pipeDown = makePipe(
            texture: pipeTextureDown,
            position: CGPoint(
                x: 0,
                y: y + pipeTextureDown.height * 2 +
                    Constants.verticalPipeGap
            )
        )

        let pipeUp = makePipe(
            texture: pipeTextureUp,
            position: CGPoint(
                x: 0,
                y: y
            )
        )

        let scoreNode = makeScoreNode()

        let distance =
            width +
            2 * pipeTextureUp.width +
            25

        let movement = SKAction.moveBy(
            x: -distance,
            y: 0,
            duration: Constants.pipeMoveSpeed * distance
        )

        let pipeGroup = SKNode().then {
            $0.position = CGPoint(
                x: width + pipeTextureUp.width * 2,
                y: -352
            )

            $0.zPosition = GameZPosition.pipe

            $0.addChild(pipeDown)
            $0.addChild(pipeUp)
            $0.addChild(scoreNode)

            $0.run(
                .sequence([
                    movement,
                    .removeFromParent()
                ])
            )
        }

        pipes.addChild(pipeGroup)
    }

    private func makePipe(
        texture: SKTexture,
        position: CGPoint
    ) -> SKSpriteNode {
        SKSpriteNode(texture: texture).then {
            $0.setScale(Constants.pipeScale)
            $0.position = position

            $0.physicsBody = SKPhysicsBody(
                rectangleOf: $0.size
            ).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCategory.pipe
                $0.contactTestBitMask = PhysicsCategory.bird
            }
        }
    }

    private func makeScoreNode() -> SKNode {
        SKNode().then {
            // Place the scoring sensor just beyond the right edge
            // of the pipe. The bird must fully clear the pipe
            // before it can trigger the score.
            $0.position = CGPoint(
                x: pipeTextureDown.width + bird.width / 2 + 2,
                y: height / 2 + 400
            )

            $0.physicsBody = SKPhysicsBody(
                rectangleOf: CGSize(
                    width: 4,
                    height: height
                )
            ).then {
                $0.isDynamic = false
                $0.categoryBitMask = PhysicsCategory.score
                $0.contactTestBitMask = PhysicsCategory.bird
                $0.collisionBitMask = 0
            }
        }
    }

    // MARK: Game Over

    private func gameOver() {
        guard !isShowingGameOver else {
            return
        }
        
        pauseButton.removeFromParent()
        resumeButton.removeFromParent()
        pauseOverlay.removeFromParent()

        isPausedByUser = false
        isPaused = false

        timeTook =
            CFAbsoluteTimeGetCurrent() - gameStartTime

        isShowingGameOver = true
        isGameOver = true
        playFlapSound = false

        if haptics {
            notificationFeedback.notificationOccurred(.error)
        }

        flashScreen(
            color: .white,
            fadeInDuration: 0.1,
            peakAlpha: 0.9,
            fadeOutDuration: 0.25
        )

        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.collisionBitMask =
            PhysicsCategory.land
        bird.physicsBody?.isDynamic = true

        applyBirdAnimation()

        playSound(hitSound)

        run(
            .sequence([
                .wait(forDuration: 0.2),
                .run { [weak self] in
                    self?.playSound(self?.dieSound)
                }
            ])
        )

        gameOverNode.setScale(0)
        addChild(gameOverNode)

        run(
            .sequence([
                .wait(forDuration: 0.1),
                .run { [weak self] in
                    self?.scoreLabelNode.removeFromParent()
                    self?.scoreLabelNodeInside.removeFromParent()
                },
                .run { [weak self] in
                    guard let self else { return }

                    self.scaleTwice(
                        node: self.gameOverNode,
                        firstScale: 1,
                        firstScaleDuration: 0.1,
                        secondScale: 1.25,
                        secondScaleDuration: 0.1
                    )
                }
            ])
        )

        moving.speed = 0

        bird.physicsBody?.velocity = .zero
        bird.physicsBody?.applyImpulse(
            CGVector(dx: 0, dy: 20)
        )
    }

    // MARK: Results

    private func addResultsAndButtons() {
        guard canShowScore else {
            return
        }

        resultNode.setScale(0)
        resultNode.score = score
        addChild(resultNode)

        scaleTwice(
            node: resultNode,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 1.25,
            secondScaleDuration: 0.1
        )

        Self.settingsButton.position = CGPoint(
            x: ScreenData.shared.width / 2,
            y: ScreenData.shared.height / 2 - 25
        )

        Self.settingsButton.setScale(0)
        addChild(Self.settingsButton)

        scaleTwice(
            node: Self.settingsButton,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 1.2,
            secondScaleDuration: 0.1
        )

        playButton.setScale(0)
        addChild(playButton)

        scaleTwice(
            node: playButton,
            firstScale: 1,
            firstScaleDuration: 0.1,
            secondScale: 1.2,
            secondScaleDuration: 0.1
        )
    }

    // MARK: Reset

    private func resetScene() {
        isPaused = false
        isPausedByUser = false

        pauseButton.removeFromParent()
        resumeButton.removeFromParent()
        pauseOverlay.removeFromParent()
        
        pipes.removeAllChildren()

        resultNode.removeFromParent()
        gameOverNode.removeFromParent()

        updateSky()

        addChild(tapTap)
        addChild(getReady)
        addChild(scoreLabelNode)
        addChild(scoreLabelNodeInside)

        scoreLabelNode.setScale(1)
        scoreLabelNodeInside.setScale(1)

        score = 0

        moving.speed = 1
        bird.speed = 1
        pipes.setScale(0)

        bird.zRotation = 0
        bird.position = CGPoint(
            x: width / 2.5,
            y: height / 2
        )

        bird.removeAllActions()
        applyBirdAnimation()

        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.velocity = .zero
        bird.physicsBody?.collisionBitMask =
            PhysicsCategory.land |
            PhysicsCategory.pipe

        hasHitGround = false
        isGameOver = false
        isShowingGameOver = false
        isWaitingToStart = true

        lastFlapTime = 0

        startIdleAnimation()
    }

    // MARK: Physics

    private func isContact(
        _ contact: SKPhysicsContact,
        with category: UInt32
    ) -> Bool {
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask

        return
            bodyA & category == category ||
            bodyB & category == category
    }

    private func handleScore() {
        score += 1

        if score == Constants.superScore {
            enableSuperBird()
        }

        if haptics {
            impactFeedback.impactOccurred()
        }

        playSound(pointSound)

        scaleTwice(
            node: scoreLabelNode,
            firstScale: 1.5,
            firstScaleDuration: 0.1,
            secondScale: 1,
            secondScaleDuration: 0.1
        )

        scaleTwice(
            node: scoreLabelNodeInside,
            firstScale: 1.5,
            firstScaleDuration: 0.1,
            secondScale: 1,
            secondScaleDuration: 0.1
        )
    }

    private func enableSuperBird() {
        for index in 0...2 {
            birdTextures[index] =
                Assets.shared.sprites.textureNamed(
                    "super-bird-\(index + 1)"
                ).then {
                    $0.filteringMode = .nearest
                }
        }

        applyBirdAnimation()
    }

    private func handlePipeCollision() {
        gameOver()
    }

    private func handleGroundCollision() {
        guard !hasHitGround else {
            return
        }

        hasHitGround = true
        bird.speed = 0.5

        if !isShowingGameOver {
            gameOver()
        }

        bird.physicsBody?.velocity = .zero

        run(
            .sequence([
                .wait(forDuration: Constants.gameOverDelay),
                .run { [weak self] in
                    self?.bird.speed = 0
                },
                .wait(forDuration: Constants.resultDelay),
                .run { [weak self] in
                    guard let self else { return }

                    self.playSound(self.swooshSound)
                    self.addResultsAndButtons()
                }
            ])
        )
    }
}

// MARK: - Physics Contact Delegate

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        guard !hasHitGround else {
            return
        }

        if !isShowingGameOver &&
            bird.speed == 1 || bird.speed == 2 {

            if isContact(
                contact,
                with: PhysicsCategory.score
            ) {
                handleScore()
                return
            }
        }

        if !isShowingGameOver &&
            isContact(
                contact,
                with: PhysicsCategory.pipe
            ) {
            handlePipeCollision()
            return
        }

        if isContact(
            contact,
            with: PhysicsCategory.land
        ) {
            handleGroundCollision()
        }
    }
}

// MARK: - UI Helpers

private extension GameScene {

    func playSound(_ sound: SKAction?) {
        guard playSounds, let sound else {
            return
        }

        run(sound)
    }

    func scaleTwice(
        node: SKNode,
        firstScale: CGFloat,
        firstScaleDuration: TimeInterval,
        secondScale: CGFloat,
        secondScaleDuration: TimeInterval
    ) {
        node.run(
            .sequence([
                .scale(
                    to: firstScale,
                    duration: firstScaleDuration
                ),
                .scale(
                    to: secondScale,
                    duration: secondScaleDuration
                )
            ])
        )
    }

    func flashScreen(
        color: UIColor,
        fadeInDuration: TimeInterval,
        peakAlpha: CGFloat,
        fadeOutDuration: TimeInterval
    ) {
        let flash = SKShapeNode(
            rect: CGRect(
                x: -5,
                y: -5,
                width: width + 10,
                height: height + 10
            )
        )

        flash.zPosition = 7
        flash.fillColor = color
        flash.alpha = 0

        addChild(flash)

        flash.run(
            .sequence([
                .fadeAlpha(
                    to: peakAlpha,
                    duration: fadeInDuration
                ),
                .fadeAlpha(
                    to: 0,
                    duration: fadeOutDuration
                ),
                .removeFromParent()
            ])
        )
    }
}
