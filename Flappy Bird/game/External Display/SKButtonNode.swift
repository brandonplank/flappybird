/*
 * Copyright (c) 2017 Konrad Bajtyngier
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

///Corresponds to button's current control state. Very much like `UIControlState` in case of `UIButton`.
public enum SKButtonNodeState {
	case normal
	case highlighted
	case disabled
}

///Simple implementation of button for `SpriteKit`. Derives much of its concepts from `UIKit`'s `UIButton`.
public class SKButtonNode: SKNode {
	
	//MARK: - Public
	
	public var action:(()->())?
	public var enabled:Bool {
		get {
			return state != .disabled
		}
		set {
			state = newValue ? .normal : .disabled
		}
	}
	
	//MARK: - Public properties derived from `SKSpriteNode`
	
	public var size:CGSize {
		get {
			return sprite.size
		}
		set {
			sprite.size = newValue
		}
	}
	
	public var texture:SKTexture? {
		get {
			return sprite.texture
		}
		set {
			sprite.texture = newValue
		}
	}
	
	public var anchorPoint:CGPoint {
		get {
			return sprite.anchorPoint
		}
		set {
			sprite.anchorPoint = newValue
		}
	}
	
	//MARK: - Private(set)
	
	private(set) var titleLabel:SKLabelNode?
	private(set) var state:SKButtonNodeState = .normal {
		didSet {
			if state != oldValue {
				updateState()
			}
		}
	}
	
	//MARK: - Computed properties
	
	public var title:String? {
		return titleLabel?.text
	}
	
	//MARK: - Private
	
	private var sprite:SKSpriteNode
	private var activated = false
	private var normalState:State
	private var highlightedState:State?
	private var disabledState:State?
	
	//MARK: - Initialization
	
	/**
	Creates a button with a texture generated from the specified image.
	- parameter imageNamed: Name of the image from assets catalog.
	- parameter title: Button's label text.
	- parameter action: Closure to be called as the button's action.
	*/
	convenience init(imageNamed:String, title:String? = nil, action:(()->())? = nil) {
		let texture = SKTexture(imageNamed: imageNamed)
		self.init(texture: texture, title: title, action: action)
	}
	
	/**
	Failing initializer that creates a button with a texture generated from the passed `SKShapeNode`.
	- parameter shape: The shape that will be used to generate a texture from.
	- parameter title: Button's `titleLabel` text.
	- parameter action: Closure to be called as the button's action.
	*/
	convenience init?(shape:SKShapeNode, title:String? = nil, action:(()->())? = nil) {
		guard let texture = SKView().texture(from: shape) else { return nil }
		self.init(texture: texture, title: title, action: action)
	}
	
	/**
	Creates a button with a passed texture.
	- parameter texture: Texture object, which will make up the button.
	- parameter title: Button's `titleLabel` text.
	- parameter action: Closure to be called as the button's action.
	*/
	init(texture:SKTexture, title:String? = nil, action:(()->())? = nil) {
		self.sprite = SKSpriteNode(texture: texture)
		self.action = action
		self.normalState = State(texture: texture)
		super.init()
		isUserInteractionEnabled = true
		addChild(sprite)
		setTitle(title)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateState() {
		//Determine current state of the button.
		var currentState:State
		switch self.state {
		case .highlighted:
			currentState = highlightedState ?? normalState
		case .disabled:
			currentState = disabledState ?? normalState
		default:
			currentState = normalState
		}
		//Update the button to match the current state.
		sprite.texture = currentState.texture
		titleLabel?.fontColor = currentState.fontColor
		alpha = currentState.alpha
		currentState.styling?()
	}
	
	//MARK: - Texture
	
	///Takes the image name and created a texture to further update the specified state with.
	public func setImage(named:String, for state:SKButtonNodeState) {
		let texture = SKTexture(imageNamed: named)
		setTexture(texture, for: state)
	}
	
	///Update the specified state with the specified texture.
	public func setTexture(_ texture:SKTexture, for state:SKButtonNodeState) {
		switch state {
		case .normal:
			normalState.texture = texture
		case .highlighted:
			if let _ = highlightedState {
				highlightedState!.texture = texture
			} else {
				highlightedState = State(texture: texture, fontColor: normalState.fontColor)
			}
		case .disabled:
			if let _ = disabledState {
				disabledState!.texture = texture
			} else {
				disabledState = State(texture: texture, fontColor: normalState.fontColor)
			}
		}
		updateState()
	}
	
	//MARK: - Title Text
	
	/**
	Update the button's titleLabel text.
	- parameter title: String, which the `titleLabel` text should be updated to. If the value is `nil`, the label node will be removed.
	*/
	public func setTitle(_ title:String?) {
		//If the title is empty, the label child is removed
		guard let title = title, title != "" else {
			titleLabel?.removeFromParent()
			titleLabel = nil
			return
		}
		//If the label child was previously created, update the text
		if let label = titleLabel {
			label.text = title
		}
		//If the title was previously empty, create a new label
		else {
			titleLabel = generateTitleLabel(text: title)
			addChild(titleLabel!)
		}
	}
	
	private func generateTitleLabel(text:String) -> SKLabelNode {
		let titleLabel = SKLabelNode(text: text)
		titleLabel.verticalAlignmentMode = .center
		titleLabel.zPosition = 1
		return titleLabel
	}
	
	//MARK: - State Styling
	
	///Set button's `titleLabel` text color.
	public func setTitleColor(_ color:SKColor, for state:SKButtonNodeState) {
		switch state {
		case .normal:
			normalState.fontColor = color
		case .highlighted:
			if let _ = highlightedState {
				highlightedState!.fontColor = color
			} else {
				highlightedState = State(texture: normalState.texture, fontColor: color)
			}
		case .disabled:
			if let _ = disabledState {
				disabledState!.fontColor = color
			} else {
				disabledState = State(texture: normalState.texture, fontColor: color)
			}
		}
		updateState()
	}
	
	/**
	Set button's alpha value.
	- parameter alpha: Value from `0.0` to `1.0`. Default is `1.0`.
	*/
	public func setAlpha(_ alpha:CGFloat, for state:SKButtonNodeState) {
		switch state {
		case .normal:
			normalState.alpha = alpha
		case .highlighted:
			if let _ = highlightedState {
				highlightedState!.alpha = alpha
			} else {
				highlightedState = State(texture: normalState.texture, alpha: alpha)
			}
		case .disabled:
			if let _ = disabledState {
				disabledState!.alpha = alpha
			} else {
				disabledState = State(texture: normalState.texture, alpha: alpha)
			}
		}
		updateState()
	}
	
	/**
	Set a styling closure, which will be called on the button.
	This feature enables you to perform any custom alterations to the button.
	- parameter styling: Closure that performs any custom changes on the button for a given state.
	*/
	public func setStyling(_ forState:SKButtonNodeState, styling:(()->())?) {
		switch state {
		case .normal:
			normalState.styling = styling
		case .highlighted:
			if let _ = highlightedState {
				highlightedState!.styling = styling
			} else {
				highlightedState = State(texture: normalState.texture, styling: styling)
			}
		case .disabled:
			if let _ = disabledState {
				disabledState!.styling = styling
			} else {
				disabledState = State(texture: normalState.texture, styling: styling)
			}
		}
		updateState()
	}
	
	//MARK: - User Interaction Handling
	
	override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let _ = touches.first, enabled else { return }
		state = .highlighted
	}
	
	override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		//This method will make sure that the use is still touching the area of the button
		guard let touch = touches.first, enabled else { return }
		let touchPoint = touch.location(in: self)
		let touchArea = CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size)
		if !touchArea.contains(touchPoint) {
			//User is out of the button area, so the button action should not be triggered
			state = .normal
		}
	}
	
	override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let _ = touches.first else { return }
		runAction()
	}
	
	override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		state = .normal
	}
	
	private func runAction() {
		if enabled && state == .highlighted {
			state = .normal
			action?()
		}
	}
	
	//MARK: - Button State
	
	///State struct represents a certain state of a `SKButtonNode`. Each state can have its own `SKTexture` and font color.
	private struct State {
		
		var texture:SKTexture?
		var alpha:CGFloat = 1.0
		var fontColor:SKColor = SKColor.white
		var styling:(()->())?
		
		init(texture:SKTexture?, alpha:CGFloat = 1.0, styling:(()->())? = nil) {
			self.texture = texture
			self.alpha = alpha
		}
		
		init(texture:SKTexture?, fontColor:SKColor, alpha:CGFloat = 1.0, styling:(()->())? = nil) {
			self.init(texture: texture, alpha: alpha, styling: styling)
			self.fontColor = fontColor
		}
		
	}
	
}
