//
//  File.swift
//  
//
//  Created by Sebastian Toivonen on 30.1.2020.
//

import Foundation
#if canImport(SpriteKit)
import SpriteKit
public class Scene: SKScene {
    private(set) var deltaTime: CGFloat = 0.0 //TODO: Should this be static?
    private var lastUpdateTime: TimeInterval = 0.0
    
    public override func update(_ currentTime: TimeInterval) {
        assignDT(currentTime)
    }
    
    private func assignDT(_ currentTime: TimeInterval) {
        let dt = CGFloat(currentTime - lastUpdateTime)
        deltaTime = dt < 1.0 ? dt : 0.0
        lastUpdateTime = currentTime
    }
}
#endif
