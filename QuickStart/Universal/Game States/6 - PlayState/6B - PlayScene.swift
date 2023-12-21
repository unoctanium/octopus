//
//  PlayScene.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018-02-10.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 6B: The "gameplay" scene for the QuickStart project.
//
//  This scene shows the content for multiple game states: PlayState, PausedState and GameOverState.
//
//  The UI is handled by the PlayUI view designed with SwiftUI.

import SpriteKit
import GameplayKit
import OctopusKit

final class PlayScene: OKScene {
    
    // MARK: - Life Cycle
    
    // MARK: 🔶 STEP 6B.1
    override func setName() -> String? {
        
        // Set the name of this scene at the earliest override-able point, for logging purposes.
        "QuickStart Play Scene"
    }
    
    // MARK: 🔶 STEP 6B.2
    override func createComponentSystems() -> [GKComponent.Type] {
        
        // This method is called by the OKScene superclass, after the scene has been loaded, to create a list of systems for each component type that must be updated in every frame of this scene.
        //
        // ❗️ The order of components is important, as the functionality of some components depends on the output of other components.
        //
        // See the code and documentation for each component to check its requirements.
        
        [
            // Components that process player input, provided by OctopusKit.
            
            OSMouseOrTouchEventComponent.self,
            PointerEventComponent.self, // This component translates touch or mouse input into an OS-agnostic "pointer" format, which is used by other input-processing components that work on iOS as well as macOS.
            PhysicsComponent.self,

            // Custom components which are specific to this QuickStart project.
            
            GlobalDataComponent.self,
            NodeSpawnerComponent.self
        ]
    }
    
    // MARK: 🔶 STEP 6B.3
    override func createContents() {
        
        // This method is called by the OKScene superclass, after the scene has been presented in a view, to let each subclass (the scenes specific to your game) create its contents and add entities to the scene.
                
        // Create the entities to present in this scene.
        
        // Set the permanent visual properties of the scene itself.
        
        self.anchorPoint = CGPoint.half
        
        // Add components to the scene entity.
        
        self.entity?.addComponents([sharedMouseOrTouchEventComponent,
                                    sharedPointerEventComponent,
                                    PhysicsWorldComponent(),
                                    PhysicsComponent(physicsBody: SKPhysicsBody(edgeLoopFrom: self.frame))])
                
        // Add the global game coordinator entity to this scene so that global components will be included in the update cycle, and updated in the order specified by this scene's `componentSystems` array.
        
        self.addEntity(OctopusKit.shared.gameCoordinator.entity)
    }
    
    // MARK: - State & Scene Transitions
    
    // MARK: 🔶 STEP 6B.4
    override func gameCoordinatorDidEnterState(_ state: GKState, from previousState: GKState?) {
        
        // This method is called by the current game state to notify the current scene when a new state has been entered.
        //
        // Calling super for this method is not necessary; it only adds a log entry.
        
        super.gameCoordinatorDidEnterState(state, from: previousState)
        
        // If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
        
        switch type(of: state) {
            
        case is PlayState.Type: // Entering `PlayState`
            
            self.backgroundColor = SKColor(red: 0.1, green: 0.2, blue: 0.2, alpha: 1.0)
            
            self.entity?.addComponent(NodeSpawnerComponent())
            
            // Add a fade-in effect if the previous state and scene was the title screen.
            
            if previousState is TitleState {
            
                let colorFill = SKSpriteNode(color: .white, size: self.frame.size)
                colorFill.alpha = 1
                colorFill.blendMode = .screen
                
                self.addChild(colorFill)
                
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 1.5).timingMode(.easeIn)
                
                colorFill.run(.sequence([
                    fadeOut,
                    .removeFromParent()
                    ]))
            }
            
        case is PausedState.Type: // Entering `PausedState`
            
            self.backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            
            // Remove the global entity from this scene so we do not update it until the game is unpaused.
            
            self.removeEntity(OctopusKit.shared.gameCoordinator.entity)
            
            // Set the scene's "paused by player" flag, because the PausedState is a state which is specific to this QuickStart project, not a feature of OctopusKit. When we manually enter this state, we must also notify OctopusKit that the player has chosen to pause the game.
            
            if !isPausedByPlayer { togglePauseByPlayer() }
            
        case is GameOverState.Type: // Entering `GameOverState`
            
            self.backgroundColor = SKColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 1.0)
            
        default: break
        }
        
    }
    
    // MARK: 🔶 STEP 6B.5
    override func gameCoordinatorWillExitState(_ exitingState: GKState, to nextState: GKState) {
        
        // This method is called by the current game state to notify the current scene when the state will transition to a new state.
        
        super.gameCoordinatorWillExitState(exitingState, to: nextState)
        
        // If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
        
        switch type(of: exitingState) {
        
        case is PlayState.Type: // Exiting `PlayState`
            
            self.entity?.removeComponent(ofType: NodeSpawnerComponent.self)
            
        case is PausedState.Type: // Exiting `PausedState`
            
            // Add the global entity back to this scene so we can resume updating it.
            
            self.addEntity(OctopusKit.shared.gameCoordinator.entity)
            
            // Clear the scene's "paused by player" flag,
            
            if isPausedByPlayer { togglePauseByPlayer() }
            
        default: break
        }
        
    }
    
    // MARK: 🔶 STEP 6B.6
    override func transition(for nextSceneClass: OKScene.Type) -> SKTransition? {
        
        // This method is called by the OKScenePresenter to ask the current scene for a transition animation between the outgoing scene and the next scene.
        //
        // Here we display transition effects if the next scene is the TitleScene.
        
        guard nextSceneClass is TitleScene.Type else { return nil }
        
        // First, apply some effects to the current scene.
        
        let colorFill = SKSpriteNode(color: .black, size: self.frame.size)
        colorFill.alpha = 0
        colorFill.zPosition = 1000
        self.addChild(colorFill)
        
        let fadeOut = SKAction.fadeAlpha(to: 1.0, duration: 1.0).timingMode(.easeIn)
        colorFill.run(fadeOut)
        
        // Next, provide the OKScenePresenter with an animation to apply between the contents of this scene and the upcoming scene.
        
        let transition = SKTransition.doorsCloseVertical(withDuration: 2.0)
        
        transition.pausesOutgoingScene = false
        transition.pausesIncomingScene = false
        
        return transition
    }
    
    // MARK: - Pausing/Unpausing
    
    override func didPauseBySystem() {
        
        // 🔶 STEP 6B.?: This method is called when the player switches to a different application, or the device receives a phone call etc.
        //
        // Here we enter the PausedState if the game was in the PlayState.
        
        if  let currentState = OctopusKit.shared.gameCoordinator.currentState,
            type(of: currentState) is PlayState.Type
        {
            self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
        }
    }

    override func didPauseByPlayer() {
        self.physicsWorld.speed = 0.0
        self.isPaused = true
    }
    
    override func didUnpauseByPlayer() {
        self.physicsWorld.speed = 1.0
        self.isPaused = false
    }
    
    // MARK: - tvOS
    
    #if os(tvOS)
    
    // 🔶 STEP 6B.?: These methods and properties ensures that both the SpriteKit gameplay and the SwiftUI buttons etc. can receive Apple TV Remote input events when appropriate.
    
    override var canBecomeFocused: Bool {
        gameCoordinator?.currentGameState is PlayState
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if  presses.contains(where: { $0.type == .playPause }) {
            gameCoordinator?.enter(PausedState.self)
            parentFocusEnvironment?.setNeedsFocusUpdate()
            parentFocusEnvironment?.updateFocusIfNeeded()
        }
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if  self.gameCoordinator?.currentGameState is PlayState {
            return [self]
        } else {
            return [self.view?.parentFocusEnvironment ?? self]
        }
    }
    
    #endif
    
}

// NEXT: See PlayUI (STEP 6C) and PausedState (STEP 7)

