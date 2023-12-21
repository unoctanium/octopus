//
//  MotionControlledGravityComponent
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2017/10/24.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import GameplayKit

#if os(iOS)
    
/// Modifies the `gravity` of a scene's `PhysicsWorldComponent` based on the input from a `MotionManagerComponent`.
///
/// **Dependencies:** `MotionManagerComponent`, `PhysicsWorldComponent`
public class MotionControlledGravityComponent: OKComponent, RequiresUpdatesPerFrame {
    
    public override var requiredComponents: [GKComponent.Type]? {
        [PhysicsWorldComponent.self,
         MotionManagerComponent.self]
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        guard
            let physicsWorld = coComponent(PhysicsWorldComponent.self)?.physicsWorld,
            let motionManagerComponent = coComponent(MotionManagerComponent.self)
            else { return }
        
        if let motion = motionManagerComponent.motionManager?.deviceMotion {
            let vector = CGVector(dx: CGFloat(motion.gravity.x), dy: CGFloat(motion.gravity.y))
            physicsWorld.gravity = vector
        }
    }
}

#else
    
public final class MotionControlledGravityComponent: iOSExclusiveComponent {}
    
#endif
