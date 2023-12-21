//
//  Component.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2020/05/21.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import Foundation
import GameplayKit

#if UseNewProtocols // ℹ️ Not currently in use; This is mostly preparation for future independence from GameplayKit, if needed.

public protocol Component: class, UpdatablePerFrame {
    
    // MARK: Properties
    
    var entity:             Entity?             { get }
    var requiredComponents: [Component.Type]?   { get }
    
    var componentType:      Component.Type      { get }
    
    var shouldRemoveFromEntityOnDeinit:    Bool { get }
    var shouldWarnIfDeinitWithoutRemoving: Bool { get }
    var disableDependencyChecks:           Bool { get set }
    
    // MARK: Life Cycle
    
    // init()
    
    @discardableResult
    func disableDependencyChecks(_ newValue: Bool) -> Self

    func didAddToEntity()
    func didAddToEntity(withNode node: SKNode)

    func removeFromEntity()

    func willRemoveFromEntity()
    func willRemoveFromEntity(withNode node: SKNode)
    
    // MARK: Queries

    func coComponent <ComponentType> (
        ofType componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool)
        -> ComponentType? where ComponentType: Component

    func coComponent <ComponentType> (
        _ componentClass: ComponentType.Type,
        ignoreRelayComponents: Bool)
        -> ComponentType? where ComponentType: Component

    @discardableResult
    func checkEntityForRequiredComponents() -> Bool
}

#endif
