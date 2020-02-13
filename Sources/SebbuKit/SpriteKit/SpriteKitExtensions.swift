//
//  SpriteKitExtenstions.swift
//  
//
//  Created by Sebastian Toivonen on 30.1.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import SpriteKit
open class Scene: SKScene {
    private(set) var deltaTime: CGFloat = 0.0
    private var lastUpdateTime: TimeInterval = 0.0
    
    open override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        assignDT(currentTime)
    }
    
    private func assignDT(_ currentTime: TimeInterval) {
        let dt = CGFloat(currentTime - lastUpdateTime)
        deltaTime = dt < 1.0 ? dt : 0.0
        lastUpdateTime = currentTime
    }
    
    open class func createLandscape(fileNamed: String, view: SKView) -> Self {
        guard let scene = SKScene(fileNamed: fileNamed) as? Self else {
            fatalError("Couldn't load scene")
        }
        scene.scaleMode = .aspectFit
        scene.size = view.frame.size.aspectFill(CGSize(width: 1334, height: 750))
        return scene
    }
    
    open class func createPortrait(fileNamed: String, view: SKView) -> Self {
        guard let scene = SKScene(fileNamed: fileNamed) as? Self else {
            fatalError("Couldn't load scene")
        }
        scene.scaleMode = .aspectFit
        scene.size = view.frame.size.aspectFill(CGSize(width: 750, height: 1334))
        return scene
    }
}

public extension SKNode {
    var rotation: CGFloat {
        get {return CGFloat(fmod(Double(zRotation), .pi * 2))}
        set { zRotation = newValue }
    }
}

public extension SKColor {
    static func randomColor() -> SKColor {
        return SKColor(red: CGFloat.random(in: 0...1),
                       green: CGFloat.random(in: 0...1),
                       blue: CGFloat.random(in: 0...1),
                       alpha: 1.0)
    }
    func complementaryColor() -> SKColor {
        var hue: CGFloat = 0
        self.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        if hue > 0.5 {
            hue -= 0.5
        } else {
            hue += 0.5
        }
        return SKColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    static var gold: SKColor {
        return SKColor(red: 255 / 255, green: 215 / 255, blue: 0, alpha: 1.0)
    }
    static var darkoliveGreen: SKColor {
        return SKColor(red: 85 / 255, green: 107 / 255, blue: 47 / 255, alpha: 1.0)
    }
    static var powderBlue: SKColor {
        return SKColor(red: 176 / 255, green: 224 / 255, blue: 230 / 255, alpha: 1.0)
    }
}

// Camera shake action
public extension SKAction {
    class func shake(duration:CGFloat, amplitudeX:Int = 3, amplitudeY:Int = 3) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveBy(x: dx, y:dy, duration: 0.015)
            let reverse = forward.reversed()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
    
    class func hermiteInterpolation(duration: CGFloat, start: CGPoint, end: CGPoint, startVelocity: CGVector, endVelocity: CGVector) -> SKAction {
        let customAction = SKAction.customAction(withDuration: TimeInterval(duration)) { (node, elapsedTime) in
            let pos = hermiteSpline(startPos: start, startVelocity: startVelocity, endPos: end, endVelocity: endVelocity, t: elapsedTime / duration)
            node.position = pos
        }
        return customAction
    }
    
    class func colorizeWithRainbow(duration: CGFloat) -> SKAction {
        let actions = [SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0)),
                       SKAction.colorize(with: .orange, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0)),
                       SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0)),
                       SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0)),
                       SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: TimeInterval(duration / 7.0))]
        return sequence(actions)
    }
    
    class func colorizeFillColor(withSequence: SKKeyframeSequence, duration: CGFloat) -> SKAction {
        let customAction = SKAction.customAction(withDuration: TimeInterval(duration)) { (node, elapsedTime) in
            let timeValue = elapsedTime / duration
            let color = withSequence.sample(atTime: timeValue) as! SKColor
            if let shape = node as? SKShapeNode {
                shape.fillColor = color
            }
        }
        return customAction
    }
    
    class func typeOut(duration: CGFloat, text: String) -> SKAction {
        let timeBetweenCharacters: CGFloat = CGFloat(duration / CGFloat(text.count))
        let typeText = text
        var elapsedTypeTime: CGFloat = 0
        var lastElapsedTime: CGFloat = 0
        var index = 0
        let customAction = SKAction.customAction(withDuration: TimeInterval(duration)) { (node, elapsedTime) in
            if let label = node as? SKLabelNode {
                let deltaTime = elapsedTime - lastElapsedTime
                lastElapsedTime = elapsedTime
                elapsedTypeTime += deltaTime
                while elapsedTypeTime > timeBetweenCharacters {
                    index += 1
                    elapsedTypeTime -= timeBetweenCharacters
                    label.text = String(typeText.dropLast(text.count - index))
                }
            }
            
        }
        return SKAction.sequence([customAction, ])
    }
    
    class func smoothFollow(path: [CGPoint], speed: CGFloat) -> SKAction {
        var distance: CGFloat = 0
        if path.count <= 1 {
            return SKAction()
        }
        for i in 0..<path.count - 1 {
            distance += path[i].distanceTo(path[i + 1])
        }
        let customAction = SKAction.customAction(withDuration: 100) { (node, elapsedTime) in

            
            
        }
        return customAction
    }
    
    class func seekTarget(targetNode: SKNode, speed: CGFloat, duration: TimeInterval) -> SKAction {
        var velocity = CGVector(dx: 0, dy: 0)
        var lastElapsedTime: CGFloat = 0
        let customAction = SKAction.customAction(withDuration: duration) { (node, elapsedTime) in
            let deltaTime = elapsedTime - lastElapsedTime
            lastElapsedTime = elapsedTime
            velocity = CGVector(point: targetNode.position - node.position)
            if velocity.length() > speed * deltaTime {
                velocity = velocity.unitVector() * speed * deltaTime
            }
            node.position += velocity
        }
        return customAction
    }
}

public extension SKSpriteNode {
    
    func removeGlow() {
        self.enumerateChildNodes(withName: "glow") { (node, void) in
            node.removeFromParent()
        }
    }
    
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.name = "glow"
        self.addChild(effectNode)
        let sprite = SKSpriteNode(texture: texture)
        sprite.blendMode = .add
        sprite.size = self.size
        effectNode.addChild(sprite)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
    }
    
    func addBlur() -> SKEffectNode {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.name = "blur"
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":200])
        return effectNode
    }
}

@available(iOS 9.0, *)
public extension SKCameraNode {
    func followNode(target: SKNode, offset: CGVector, smoothTime: CGFloat, currentVelocity: inout CGVector, dt: CGFloat) {
        position = smoothDamp(currentPosition: position, targetPosition: target.position + offset, currentVelocity: &currentVelocity, smoothTime: smoothTime, deltaTime: dt)
        
    }
}

public extension SKPhysicsBody {
    var kineticEnergy: CGFloat {
        get {
            return 0.5 * mass * velocity.lengthSquared()
        }
    }
    
    var potentialEnergy: CGFloat {
        get {
            guard let node = node else {
                return 0
            }
            return mass * 9.81 * node.position.y
        }
    }
}

public extension SKLabelNode {
    
    func setText(_ text: String) {
        self.text = text
        (childNode(withName: "shadow") as? SKLabelNode)?.text = text
    }
    
}

@available(iOS 9.0, *)
public extension SKTexture {
    func getPixelColor(pos: CGPoint) -> SKColor {
        let pixelData = self.cgImage().dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size().width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return SKColor(red: r, green: g, blue: b, alpha: a)
    }
    func getAveragePixelColor() -> SKColor {
        let pixelData = self.cgImage().dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        for x in 0...Int(self.size().width) {
            for y in 0...Int(self.size().height) {
                let pixelInfo: Int = ((Int(self.size().width) * y) + x) * 4
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
                r += CGFloat(data[pixelInfo]) / CGFloat(255.0) * a
                g += CGFloat(data[pixelInfo+1]) / CGFloat(255.0) * a
                b += CGFloat(data[pixelInfo+2]) / CGFloat(255.0) * a
            }
        }
        
        r /= self.size().width * self.size().height
        g /= self.size().width * self.size().height
        b /= self.size().width * self.size().height
        
        return SKColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension SKShapeNode {
    public static func roundedRect(width: CGFloat, height: CGFloat) -> SKShapeNode{
        let path = CGMutablePath()
        path.move(to: CGPoint(x: width, y: 0))
        for theta in stride(from: 0, to: 2 * CGFloat.pi, by: 0.2) {
            let na: CGFloat = 2 / 4
            let x = CGFloat(pow(abs(cos(theta)), na) * width * CGFloat(sign(cos(Double(theta)))))
            let y = CGFloat(pow(abs(sin(theta)), na) * height * CGFloat(sign(sin(Double(theta)))))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.closeSubpath()
        return SKShapeNode(path: path, centered: true)
    }
    
    public static func shape(width: CGFloat, height: CGFloat, withCorners corners: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: width, y: 0))
        for theta in stride(from: 0, to: 2 * CGFloat.pi, by: 2 * CGFloat.pi / corners) {
            let x = cos(theta) * width
            let y = sin(theta) * height
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.closeSubpath()
        let shapenode = SKShapeNode(path: path, centered: true)
        shapenode.lineCap = .round
        shapenode.name = "shape_\(Int(corners))"
        return shapenode
    }
    
    public static func upArrowTop(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: -height / 2))
        let shapeNode = SKShapeNode(path: path, centered: true)
        shapeNode.lineCap = .round
        return shapeNode
    }
    
    public static func downArrowTop(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: height / 2))
        path.addLine(to: CGPoint(x: 0, y: -height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: height / 2))
        let shapeNode = SKShapeNode(path: path, centered: true)
        shapeNode.lineCap = .round
        return shapeNode
    }
    
    public static func thunderBolt(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        var points = [CGPoint(x: width / 4.0, y: 7.0 * height / 8.0),
                      CGPoint(x: width / 8, y: height / 2.0),
                      CGPoint(x: width * 3.0 / 8.0, y: height / 2.0),
                      CGPoint(x: width / 4.0, y: height / 8.0),
                      CGPoint(x: width * 7.0 / 8.0, y: height * 5.0 / 8.0),
                      CGPoint(x: width * 5.0 / 8.0, y: height * 5.0 / 8.0),
                      CGPoint(x: width * 6.0 / 8.0, y: height * 7.0 / 8.0),
                      CGPoint(x: width / 4.0, y: height * 7.0 / 8.0)]
        for point in points {
            if let index = points.firstIndex(of: point) {
                points[index] -= 0.5 * CGPoint(x: width, y: height)
            }
        }
        path.addLines(between: points)
        let shapeNode = SKShapeNode(path: path, centered: true)
        shapeNode.fillColor = .yellow
        shapeNode.strokeColor = .black
        shapeNode.lineWidth = 5
        shapeNode.lineCap = .round
        shapeNode.lineJoin = .round
        return shapeNode
    }
    
}

class GridNode: SKSpriteNode {
    var rows:Int!
    var cols:Int!
    var blockSize:CGFloat!
    
    convenience init(blockSize:CGFloat,rows:Int,cols:Int) {
        guard let texture = GridNode.gridTexture(blockSize: blockSize,rows: rows, cols:cols) else {
            self.init()
            return
        }
        self.init(texture: texture, color:SKColor.clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    class func gridTexture(blockSize:CGFloat,rows:Int,cols:Int) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        SKColor.lightGray.setStroke()
        bezierPath.lineWidth = 1.2
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset = CGFloat(blockSize / 2.0 + 0.5)
        let a = CGFloat(col) * blockSize
        let b = (blockSize * CGFloat(cols)) / 2.0
        let x = a - b + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x:x, y:y)
    }
}

@available(iOS 9.0, *)
public extension SKAttributeValue {

    /**
     Convenience initializer to create an attribute value from a CGSize.
     - Parameter size: The input size; this is usually your node's size.
    */
    convenience init(size: CGSize) {
        let size = vector_float2(Float(size.width), Float(size.height))
        self.init(vectorFloat2: size)
    }
}

@available(iOS 9.0, *)
public extension SKShader {
    /**
     Convience initializer to create a shader from a filename by way of a string.
     Although this approach is less efficient than loading directly from disk, it enables
     shader errors to be printed in the Xcode console.

     - Parameter filename: A filename in your bundle, including extension.
     - Parameter uniforms: An array of SKUniforms to apply to the shader. Defaults to nil.
     - Parameter attributes: An array of SKAttributes to apply to the shader. Defaults to nil.
    */
    convenience init(fromFile filename: String, uniforms: [SKUniform]? = nil, attributes: [SKAttribute]? = nil) {
        // it is a fatal error to attempt to load a missing or corrupted shader
        guard let path = Bundle.main.path(forResource: filename, ofType: "fsh") else {
            fatalError("Unable to find shader \(filename).fsh in bundle")
        }

        guard let source = try? String(contentsOfFile: path) else {
            fatalError("Unable to load shader \(filename).fsh")
        }

        // if we were sent any uniforms then apply them immediately
        if let uniforms = uniforms {
            self.init(source: source as String, uniforms: uniforms)
        } else {
            self.init(source: source as String)
        }

        // if we were sent any attributes then apply those too
        if let attributes = attributes {
            self.attributes = attributes
        }
    }
}

public extension SKUniform {
    /**
    Convenience initializer to create an SKUniform from an SKColor.
    - Parameter name: The name of the uniform inside the shader, e.g. u_color.
    - Parameter color: The SKColor to set.
    */
    @available(iOS 10.0, *)
    convenience init(name: String, color: SKColor) {
        #if os(macOS)
            guard let converted = color.usingColorSpace(.deviceRGB) else {
                fatalError("Attempted to use a color that is not expressible in RGB.")
            }

            let colors = vector_float4([Float(converted.redComponent), Float(converted.greenComponent), Float(converted.blueComponent), Float(converted.alphaComponent)])
        #else
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0

            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            let colors = vector_float4([Float(r), Float(g), Float(b), Float(a)])
        #endif

        self.init(name: name, vectorFloat4: colors)
    }

    /**
     Convenience initializer to create an SKUniform from a CGSize.
     - Parameter name: The name of the uniform inside the shader, e.g. u_size.
     - Parameter color: The CGSize to set.
     */
    @available(iOS 10.0, *)
    convenience init(name: String, size: CGSize) {
        let size = vector_float2(Float(size.width), Float(size.height))
        self.init(name: name, vectorFloat2: size)
    }

    /**
     Convenience initializer to create an SKUniform from a CGPoint.
     - Parameter name: The name of the uniform inside the shader, e.g. u_center.
     - Parameter color: The CGPoint to set.
     */
    @available(iOS 10.0, *)
    convenience init(name: String, point: CGPoint) {
        let point = vector_float2(Float(point.x), Float(point.y))
        self.init(name: name, vectorFloat2: point)
    }
}

/// Relay control events though `ThumbStickNodeDelegate`.
public protocol ThumbStickNodeDelegate: class {
    /// Called when `touchPad` is moved. Values are normalized between [-1.0, 1.0].
    func thumbStickNode(thumbStickNode: ThumbStickNode, didUpdateXValue xValue: CGFloat, yValue: CGFloat)
    
    /// Called to indicate when the `touchPad` is initially pressed, and when it is released.
    func thumbStickNode(thumbStickNode: ThumbStickNode, isPressed: Bool)
}

/// Touch representation of a classic analog stick.
public class ThumbStickNode: SKSpriteNode {
    // MARK: Properties
    
    /// The actual thumb pad that moves with touch.
    var touchPad: SKSpriteNode
    
    public weak var delegate: ThumbStickNodeDelegate?
    
    /// The center point of this `ThumbStickNode`.
    let center: CGPoint
    
    /// The distance that `touchPad` can move from the `touchPadAnchorPoint`.
    let trackingDistance: CGFloat
    
    /// Styling settings for the thumbstick's nodes.
    let normalAlpha: CGFloat = 0.5
    let selectedAlpha: CGFloat = 0.85
    
    
    override public var alpha: CGFloat {
        didSet {
            touchPad.alpha = alpha
        }
    }
    
    // MARK: Initialization
    
    public init(size: CGSize) {
        trackingDistance = size.width / 2
        
        let touchPadLength = size.width / 2.2
        center = CGPoint(x: size.width / 2 - touchPadLength, y: size.height / 2 - touchPadLength)
        
        let touchPadSize = CGSize(width: touchPadLength, height: touchPadLength)
        let touchPadTexture = SKTexture(imageNamed: "control_pad")
        
        // `touchPad` is the inner touch pad that follows the user's thumb.
        touchPad = SKSpriteNode(texture: touchPadTexture, color: UIColor.darkGray, size: touchPadSize)
        
        super.init(texture: touchPadTexture, color: UIColor.darkGray, size: size)
        colorBlendFactor = 1.0
        touchPad.colorBlendFactor = 1.0
        alpha = normalAlpha
        
        addChild(touchPad)
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIResponder
    
    override public var canBecomeFirstResponder: Bool { true }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Highlight that the control is being used by adjusting the alpha.
        alpha = selectedAlpha
        
        // Inform the delegate that the control is being pressed.
        delegate?.thumbStickNode(thumbStickNode: self, isPressed: true)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        // For each touch, calculate the movement of the touchPad.
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            var dx = touchLocation.x - center.x
            var dy = touchLocation.y - center.y
            
            // Calculate the distance from the `touchPadAnchorPoint` to the current location.
            let distance = hypot(dx, dy)
            
            /*
                If the distance is greater than our allowed `trackingDistance`,
                create a unit vector and multiply by max displacement
                (`trackingDistance`).
            */
            if distance > trackingDistance {
                dx = (dx / distance) * trackingDistance
                dy = (dy / distance) * trackingDistance
            }
            
            // Position the touchPad to match the touch's movement.
            touchPad.position = CGPoint(x: center.x + dx, y: center.y + dy)
            
            // Normalize the displacements between [-1.0, 1.0].
            let normalizedDx = CGFloat(dx / trackingDistance)
            let normalizedDy = CGFloat(dy / trackingDistance)
            delegate?.thumbStickNode(thumbStickNode: self, didUpdateXValue: normalizedDx, yValue: normalizedDy)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // If the touches set is empty, return immediately.
        guard !touches.isEmpty else { return }
        
        resetTouchPad()
   }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        resetTouchPad()
    }
    
    /// When touches end, reset the `touchPad` to the center of the control.
    internal func resetTouchPad() {
        alpha = normalAlpha
        
        let restoreToCenter = SKAction.move(to: CGPoint.zero, duration: 0.2)
        restoreToCenter.timingMode = .easeInEaseOut
        touchPad.run(restoreToCenter)
        
        delegate?.thumbStickNode(thumbStickNode: self, isPressed: false)
        delegate?.thumbStickNode(thumbStickNode: self, didUpdateXValue: 0, yValue: 0)
    }
}


#endif
