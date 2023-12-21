//___FILEHEADER___

import SwiftUI
import SpriteKit
import GameplayKit
import OctopusKit

// MARK: - Game State

final class ___FILEBASENAMEASIDENTIFIER___: OKGameState {
    
    init() {
        // NOTE: Game state classes are initialized when the game coordinator is initialized: on game launch.
        super.init(associatedSceneClass:  ___FILEBASENAMEASIDENTIFIER___Scene.self,
                   associatedSwiftUIView: ___FILEBASENAMEASIDENTIFIER___UI())
    }
        
    override var validNextStates: [OKState.Type] {
        // Customize: Specify the valid states that this state can transition to.
        // NOTE: Do not perform any logic to conditionally control state transitions here. See `OKState` documentation.
        []  // Default: allow all states.
    }
    
}

// MARK: - Scene

final class ___FILEBASENAMEASIDENTIFIER___Scene: OKScene {
    
    override func setName() -> String? { "___FILEBASENAMEASIDENTIFIER___Scene" }
    
    override func createComponentSystems() -> [GKComponent.Type] {
        // Customize. Each component must be listed after the components it depends on (as per its `requiredComponents` property.)
        // See OKScene.createComponentSystems() for the default set of commonly-used systems.
        super.createComponentSystems()
    }
    
    override func createContents() {
        // Customize: This is where you construct entities to add to your scene.
        
        // Access these shared components from child entities with `RelayComponent(for:)`
        self.entity?.addComponents([sharedMouseOrTouchEventComponent,
                                    sharedPointerEventComponent])
        
        self.anchorPoint = .half // This places nodes with a position of (0,0) at the center of the scene.
        
        addEntity(OKEntity(name: "", components: [
            // Customize
        ]))
    }
    
}

// MARK: - UI

struct ___FILEBASENAMEASIDENTIFIER___UI: View {

    @EnvironmentObject var gameCoordinator: OKGameCoordinator
    
    var body: some View {
        <#Text("___FILEBASENAMEASIDENTIFIER___").font(.largeTitle).foregroundColor(.gray)#>
    }
    
}

struct ___FILEBASENAMEASIDENTIFIER___UI_Previews: PreviewProvider {
    static var previews: some View {
        ___FILEBASENAMEASIDENTIFIER___UI()
            // .environmentObject(gameCoordinator)
    }
}
