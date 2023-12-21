//
//  TouchControlledRotationComponent.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/04/14.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

// TODO: Tests

import SpriteKit
import GameplayKit

#if canImport(UIKit)

/// Modifies the `zRotation` of the entity's `NodeComponent` node to gradually turn it towards the touch location as received via a `TouchEventComponent`.
///
/// See also: `PositionSeekingGoalComponent` and `TouchControlledSeekingComponent`
///
/// **Dependencies:** `NodeComponent`, `TouchEventComponent`
@available(iOS 13.0, *)
public final class TouchControlledRotationComponent: OKComponent, RequiresUpdatesPerFrame {
    
    // TODO: Tests
    
    public override var requiredComponents: [GKComponent.Type]? {
        [NodeComponent.self,
         TouchEventComponent.self]
    }
    
    /// The amount to rotate the node by in a single update, with optional acceleration.
    public var radiansPerUpdate: AcceleratedValue<CGFloat>
    
    /// Specifies a fixed or variable time step for per-update changes.
    public var timeStep: TimeStep
    
    /// If `true`, `radiansPerUpdate` is reset to its base value when there is no rotation, for realistic inertia.
    ///
    /// `radiansPerUpdate` is always reset when there is no player input.
    public var resetAccelerationWhenNoMovement: Bool
    
    /// - Parameters:
    ///   - radiansPerUpdate: The amount of rotation to apply every update, with optional acceleration. Affected by `timeStep`.
    ///   - timeStep: Specifies a fixed or variable time step for per-update changes. Default: `.perSecond`
    ///   - resetAccelerationWhenNoMovement: When `true`, `radiansPerUpdate` is reset to its base value when there is no rotation. Default: `true`
    public init(radiansPerUpdate:                AcceleratedValue<CGFloat>,
                timeStep:                        TimeStep = .perSecond,
                resetAccelerationWhenNoMovement: Bool = true)
    {
        self.radiansPerUpdate = radiansPerUpdate
        self.timeStep = timeStep
        self.resetAccelerationWhenNoMovement = resetAccelerationWhenNoMovement
        super.init()
    }
    
    /// - Parameters:
    ///   - radiansPerUpdate: The amount of rotation to apply every update. Affected by `timeStep`.
    ///   - timeStep: Specifies a fixed or variable time step for per-update changes. Default: `.perSecond`
    ///   - acceleration: The amount to increase the rotation by on every update, while there is pointer input. The rotation is reset to `radiansPerUpdate` when there is no input. Affected by `timeStep`.
    ///   - maximum: The maximum permitted rotation per update.
    ///   - resetAccelerationWhenNoMovement: When `true`, `radiansPerUpdate` is reset to its base value when there is no rotation. Default: `true`
    public convenience init(radiansPerUpdate:   CGFloat  = 1.0, // ÷ 60 = 0.01666666667 per frame
                            acceleration:       CGFloat  = 0,
                            maximum:            CGFloat  = 1.0,
                            timeStep:           TimeStep = .perSecond,
                            resetAccelerationWhenNoMovement: Bool = true)
    {
        self.init(radiansPerUpdate: AcceleratedValue<CGFloat>(base:    radiansPerUpdate,
                                                              current: radiansPerUpdate,
                                                              maximum: maximum,
                                                              minimum: 0,
                                                              acceleration: acceleration),
                  timeStep: timeStep,
                  resetAccelerationWhenNoMovement: resetAccelerationWhenNoMovement)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable
    public override func update(deltaTime seconds: TimeInterval) {
        
        // CHECK: Would it be more natural to follow the LATEST touch instead of just the first?
        
        guard
            let node  = entityNode,
            let scene = node.scene,
            let touchEventComponent = coComponent(TouchEventComponent.self),
            let touch = touchEventComponent.touches.first
            else {
                 radiansPerUpdate.reset() // TODO: PERFORMANCE: Figure out a better way than setting this every update.
                return
        }
        
        // #1: Get the target angle to rotate towards.
        
        let touchLocation  = touch.location(in: scene) // TODO: Verify with nested nodes etc.
        let targetRotation = node.position.radians(to: touchLocation) //CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        
        // #2: Calculate the maximum rotation for this update.
        
        let rotationAmountForCurrentFrame = timeStep.applying(radiansPerUpdate.current, deltaTime: CGFloat(seconds))
        
        // #3: Just snap and exit if we're already aligned or the difference is very small.
                
        // DESIGN: We do not use `CGFloat.rotated(towards:by:)` because we need some extra logic here, like resetting the acceleration.
        
        guard abs(targetRotation - node.zRotation) > abs(rotationAmountForCurrentFrame) else {
            if resetAccelerationWhenNoMovement { radiansPerUpdate.reset() }
            node.zRotation = targetRotation
            return
        }
        
        // #4: Decide the direction to rotate in.
        
        var rotationToApply = node.zRotation // CHECK: .truncatingRemainder(dividingBy: .pi * 2)
        let delta = node.zRotation.deltaBetweenAngle(targetRotation)
        
        if  delta > 0 {
            rotationToApply += rotationAmountForCurrentFrame
            
        } else if delta < 0 {
            rotationToApply -= rotationAmountForCurrentFrame
        }
        
        // #5: Snap to the target angle if we passed it this frame.
        
        if  abs(delta) < abs(rotationAmountForCurrentFrame) {
            rotationToApply = targetRotation
        }
        
        // #6: Apply the calculated rotation.
        
        #if LOGINPUTEVENTS
        debugLog("node.zRotation = \(node.zRotation) → \(rotationToApply), targetRotation = \(targetRotation), rotationAmountForCurrentFrame = \(rotationAmountForCurrentFrame), radiansPerUpdate = \(radiansPerUpdate)")
        #endif
        
        node.zRotation = rotationToApply
        
        // #4: Apply any acceleration, and clamp the speed to the pre-specified bounds.
        
        if  radiansPerUpdate.isWithinBounds { // CHECK: PERFORMANCE
            radiansPerUpdate.update(timeStep: timeStep, deltaTime: CGFloat(seconds))
            radiansPerUpdate.clamp()
        }
    }
}


#endif

#if !canImport(UIKit)
@available(macOS, unavailable, message: "Use PointerControlledRotationComponent")
public final class TouchControlledRotationComponent: iOSExclusiveComponent {}
#endif

