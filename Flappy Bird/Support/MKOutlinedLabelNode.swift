//
//  MKOutlinedLabelNode.swift
//
//  Created by Mario Klaver on 13-8-2015.
//  Copyright (c) 2015 Endpoint ICT. All rights reserved.
//
import UIKit
import SpriteKit

class MKOutlinedLabelNode: SKLabelNode {
    
    var borderColor: UIColor = UIColor.black
    var borderWidth: CGFloat = 7.0
    var borderOffset : CGPoint = CGPoint(x: 0, y: 0)
    enum borderStyleType {
        case over
        case under
    }
    var borderStyle = borderStyleType.under
    
    var outlinedText: String! {
        didSet { drawText() }
    }
    
    private var border: SKShapeNode?
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override init() { super.init() }
    
    init(fontNamed fontName: String!, fontSize: CGFloat) {
        super.init(fontNamed: fontName)
        self.fontSize = fontSize
    }
    
    func drawText() {
        if let borderNode = border {
            borderNode.removeFromParent()
            border = nil
        }
        
        if let text = outlinedText {
            self.text = text
            if let path = createBorderPathForText() {
                let border = SKShapeNode()
                
                border.strokeColor = borderColor
                border.lineWidth = borderWidth;
                border.path = path
                border.position = positionBorder(border: border)
                switch self.borderStyle {
                    case borderStyleType.over:
                        border.zPosition = self.zPosition + 1
                        break
                    default:
                        border.zPosition = self.zPosition - 1
                }
                
                addChild(border)
                
                self.border = border
            }
        }
    }
    
    private func getTextAsCharArray() -> [UniChar] {
        var chars = [UniChar]()
        
        for codeUnit in (text?.utf16)! {
            chars.append(codeUnit)
        }
        return chars
    }
    
    private func createBorderPathForText() -> CGPath? {
        let chars = getTextAsCharArray()
        let borderFont = CTFontCreateWithName((self.fontName as CFString?)!, self.fontSize, nil)
        
        var glyphs = Array<CGGlyph>(repeating: 0, count: chars.count)
        let gotGlyphs = CTFontGetGlyphsForCharacters(borderFont, chars, &glyphs, chars.count)
        
        if gotGlyphs {
            var advances = Array<CGSize>(repeating: CGSize(), count: chars.count)
            CTFontGetAdvancesForGlyphs(borderFont, CTFontOrientation.horizontal, glyphs, &advances, chars.count);
            
            let letters = CGMutablePath()
            var xPosition = 0 as CGFloat
            for index in 0...(chars.count - 1) {
                let letter = CTFontCreatePathForGlyph(borderFont, glyphs[index], nil)
                let t = CGAffineTransform(translationX: xPosition , y: 0)
                letters.addPath(letter!, transform: t)
                xPosition = xPosition + advances[index].width
            }
            
            return letters
        } else {
            return nil
        }
    }
    
    private func positionBorder(border: SKShapeNode) -> CGPoint {
        let sizeText = self.calculateAccumulatedFrame()
        let sizeBorder = border.calculateAccumulatedFrame()
        let offsetX = sizeBorder.width - sizeText.width
        
        switch self.horizontalAlignmentMode {
        case SKLabelHorizontalAlignmentMode.center:
            return CGPoint(x: -(sizeBorder.width / 2) + offsetX/2.0 + self.borderOffset.x, y: 1 + self.borderOffset.y)
        case SKLabelHorizontalAlignmentMode.left:
            return CGPoint(x: sizeBorder.origin.x - self.borderWidth*2 + offsetX + self.borderOffset.x, y: 1 + self.borderOffset.y)
        default:
            return CGPoint(x: sizeBorder.origin.x - sizeText.width - self.borderWidth*2 + offsetX + self.borderOffset.x, y: 1 + self.borderOffset.y)
        }
    }
}
