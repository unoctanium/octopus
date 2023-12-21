//
//  TitleScene.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 5B: The title screen for the QuickStart project.
//
//  The user interface is described in TitleUI.swift (STEP 5C)

import SpriteKit
import GameplayKit
import OctopusKit

final class TitleScene: OKScene {
    
    // MARK: - Life Cycle
    
    // MARK: 🔶 STEP 5B.1
    override func setName() -> String? {
        
        // Set the name of this scene at the earliest override-able point, for logging purposes.
        "QuickStart Title Scene"
    }
    
    // MARK: 🔶 STEP 5B.2
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
            
            // Custom components which are specific to this QuickStart project.
            
            GlobalDataComponent.self,
            TitleEffectsComponent.self
        ]
    }
    
    // MARK: 🔶 STEP 5B.3
    override func createContents() {
        
        // This method is called by the OKScene superclass, after the scene has been presented in a view, to let each subclass (the scenes specific to your game) create its contents and add entities to the scene.
        
        // Set the permanent visual properties of the scene itself.
        
        self.anchorPoint = CGPoint.half
        self.backgroundColor = SKColor(red: 0.2, green: 0.1, blue: 0.5, alpha: 1.0)
            
        // Add components to the scene entity.
        
        self.entity?.addComponent(TitleEffectsComponent())
        
        // Create a label to display the game's title.
        
        // First we create a SpriteKit node.
        
        let title = SKLabelNode(text: "TOTALLY RAD GAME™",
                                font: OKFont(name: "AvenirNextCondensed-Bold",
                                                  size: 40,
                                                  color: .white))
        
        title.alignment(horizontal: .center, vertical: .top)
        
        title.position = CGPoint(x: 0,
                                 y: self.frame.size.halved.height - title.frame.size.halved.height)
        
        title.insetPositionBySafeArea(at: .top, forView: self.view)
        
        // Create a SKEffectNode so we can add a cool shader effect to the title to make it funky, otherwise we should just have used a SwiftUI text view. :)
        
        let effectNode = SKEffectNode(children: [title])
        effectNode.alpha = 0.8
        effectNode.blendMode = .screen
        
        let shader = SKShader(source: """
            void main() {
                vec2 uv = v_tex_coord;
                float xTimeFactor = 1.0;
                float yTimeFactor = 1.0;

                uv.x += (sin((uv.y + (u_time * xTimeFactor)) * 15.0) * 0.0029) +
                (sin((uv.y + (u_time * 0.1)) * 15.0) * 0.002);

                uv.y += (cos((uv.y + (u_time * yTimeFactor)) * 45.0) * 0.0019) +
                (cos((uv.y + (u_time * 0.1)) * 10.0) * 0.002);

                gl_FragColor = texture2D(u_texture, uv); }
            """)
        
        // Then we create an entity with the effect node (which contains the label node.)
        
        self.addEntity(OKEntity(name: "TitleEntity", components: [
            NodeComponent(node: effectNode),
            ShaderComponent(shader: shader)
            ]))
        
        // Add the global game coordinator entity to this scene so that global components will be included in the update cycle, and updated in the order specified by this scene's `componentSystems` array.
        
        self.addEntity(OctopusKit.shared.gameCoordinator.entity)

    }

    // MARK: - State & Scene Transitions
    
    // MARK: 🔶 STEP 5B.4
    override func transition(for nextSceneClass: OKScene.Type) -> SKTransition? {
        
        // This method is called by the game coordinator (via the OKScenePresenter protocol) to ask the current scene for a transition animation between the outgoing scene and the next scene.
        //
        // Here we display transition effects if the next scene is the PlayScene.
        
        guard nextSceneClass is PlayScene.Type else { return nil }
        
        // First, apply some effects to the current scene.
        
        let colorFill = SKSpriteNode(color: .black, size: self.frame.size)
        colorFill.alpha = 0
        colorFill.zPosition = 1000
        self.addChild(colorFill)
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1.0).timingMode(.easeIn)
        colorFill.run(fadeIn)
        
        // Next, provide the OKScenePresenter with an animation to apply between the contents of this scene and the upcoming scene.
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 2.0)
        
        transition.pausesOutgoingScene = false
        transition.pausesIncomingScene = false
        
        return transition
    }
    
}

// NEXT: See TitleUI (STEP 5C) and PlayState (STEP 6)
