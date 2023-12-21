//
//  SKNodeWithLighting.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/06/05.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

/// A protocol for nodes that have a `lightingBitMask` property..
///
/// This allows different `SKNode` subclasses to be handled together when processing lighting.
public protocol SKNodeWithLighting: AnyObject { // where Self: SKNode { // ⚠️ Crashes.
    // TODO: Change name to an adjective?
    
    // Lighting a Sprite with Light Nodes: https://developer.apple.com/documentation/spritekit/sklightnode/lighting_a_sprite_with_light_nodes
    
    var  lightingBitMask: UInt32 { get set }
    
    func lightingBitMask(_ mask: LightCategories) -> Self
}

public extension SKNodeWithLighting {
    
    // MARK: - Modifiers
    // As in SwiftUI.
    
    /// Sets the lighting categories that this node belongs to, then returns the node.
    ///
    /// A convenient alternative to setting the `lightingBitMask` property, using an `OptionSet` instead of a `UInt32` value. See the documentation for `LightCategories`.
    @inlinable @discardableResult
    func lightingBitMask(_ mask: LightCategories) -> Self {
        self.lightingBitMask = mask.rawValue
        return self
    }
}

extension SKTileMapNode:    SKNodeWithLighting {}

extension SKSpriteNode:     SKNodeWithLighting {
    
    /// Defines which lights add shadows to the sprite, then returns the sprite.
    ///
    /// A convenient alternative to setting the `shadowedBitMask` property, using an `OptionSet` instead of a `UInt32` value. See the documentation for `LightCategories`.
    @inlinable @discardableResult
    public func shadowedBitMask(_ mask: LightCategories) -> Self {
        // https://developer.apple.com/documentation/spritekit/skspritenode/1519974-shadowedbitmask
        self.shadowedBitMask = mask.rawValue
        return self
    }
    
    /// Defines which lights are occluded by this sprite, then returns the sprite.
    ///
    /// A convenient alternative to setting the `shadowCastBitMask` property, using an `OptionSet` instead of a `UInt32` value. See the documentation for `LightCategories`.
    @inlinable @discardableResult
    public func shadowCastBitMask(_ mask: LightCategories) -> Self {
        // https://developer.apple.com/documentation/spritekit/skspritenode/1520325-shadowcastbitmask
        self.shadowCastBitMask = mask.rawValue
        return self
    }
    
}
