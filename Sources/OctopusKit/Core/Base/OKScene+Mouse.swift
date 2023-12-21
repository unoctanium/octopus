//
//  OKScene+Mouse.swift
//  OctopusKit
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/11/2.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

import SpriteKit

#if canImport(AppKit)

extension OKScene: MouseEventProvider {

    // TODO: Eliminate code duplication between OKScene+Mouse and OKSubscene+Mouse
    
    // MARK: - Player Input (macOS Mouse)
    
    /// Relays mouse-input events to the scene's `MouseEventComponent`.
    open override func mouseEntered(with event: NSEvent) {
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[MouseEventComponent.self]?.mouseEntered = MouseEventComponent.MouseEvent(event: event, node: self)
    }

    /// Relays mouse-input events to the scene's `MouseEventComponent`.
    open override func mouseMoved(with event: NSEvent) {
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[MouseEventComponent.self]?.mouseMoved = MouseEventComponent.MouseEvent(event: event, node: self)
    }
    
    /// Relays mouse-input events to the scene's `MouseEventComponent`.
    open override func mouseDown(with event: NSEvent) {
        #if LOGINPUTEVENTS
        debugLog()
        #endif
                
        self.entity?[MouseEventComponent.self]?.mouseDown = MouseEventComponent.MouseEvent(event: event, node: self)
    }
    
    /// Relays mouse-input events to the scene's `MouseEventComponent`.
    open override func mouseDragged(with event: NSEvent) {
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[MouseEventComponent.self]?.mouseDragged = MouseEventComponent.MouseEvent(event: event, node: self)
    }
    
    /// Relays mouse-input events to the scene's `MouseEventComponent`.
    open override func mouseUp(with event: NSEvent) {
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[MouseEventComponent.self]?.mouseUp = MouseEventComponent.MouseEvent(event: event, node: self)
    }
    
    /// Relays mouse-input events to the scene's `MouseEventComponent`.
    open override func mouseExited(with event: NSEvent) {
        #if LOGINPUTEVENTS
        debugLog()
        #endif
        
        self.entity?[MouseEventComponent.self]?.mouseExited = MouseEventComponent.MouseEvent(event: event, node: self)
    }
}

#endif
