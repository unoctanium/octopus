---
permalink: documentation/architecture.html
---

# OctopusKit Architecture

1. [Folder Organization](#folder-organization)
2. [Control Flow & Object Hierarchy](#control-flow--object-hierarchy)
3. [Game Coordinator and Game States](#game-coordinator-and-game-states)
4. [Scenes](#scenes)
5. [User Interface](#user-interface)
6. [Entities](#entities)
7. [Components](#components)
8. [State Machines](#state-machines)
9. [Further Reading](#further-reading)

##### Related Documentation

* [QuickStart][quickstart]
* [Usage Guide][guide]
* [Tips & Troubleshooting][tips]
* [Coding Conventions & Design Decisions][conventions-&-design]
* [TODO & Roadmap][todo]

##### Notes

* This documentation assumes that the reader has some prior experience with developing for Apple platforms in the Swift programming language.

* Currently, API documentation (i.e. for types/methods/properties) is only provided via extensive source-code comments, which can be viewed in Xcode's Quick Help.

    > This guide provides a detailed overview of the engine architecture, but there is no standalone reference for the API, as I don't have the time and energy to write that alongside developing the engine. (´･_･`)  
    >
    > The best way to learn may be to examine the engine source code.
        
## Folder Organization

- `Apple API Extensions`: Adds engine-specific functionality and general conveniences to the types provided by Apple frameworks.


- `Components`: A library of components for graphics, physics, UI and other aspects of a game. Although most are marked `final` by default (to improve performance by [reducing dynamic dispatch][reducing-dynamic-dispatch]), you may remove that keyword to extend them as needed.

- `Core/Base`: The base classes for game states, scenes, entities, components and 
systems. A typical game will create multiple instances of these objects.

- `Core/Launch`: The objects that launch your game and manage the OctopusKit environment. These are mostly unique objects, which a game will generally have only one instance of.

    > 💡 If your project crashes on startup, i.e. immediately returns to the home screen without showing anything, the classes in this folder are where you should look first.
        
- `Entities`: Provides classes to quickly construct entities for common tasks, such as sprite-based buttons, from groups of standard components.

- `Miscellaneous`: Rarely used or experimental objects.

- `Scene Templates`: Prebuilt scenes, such as the OctopusKit logo.

- `Support & Utility`: Auxiliary classes and data structures that are required for common OctopusKit functionality, such as logging, but may not always be needed. Advanced projects may exclude these or use custom implementations.

- `SwiftUI`: Support for integrating SpriteKit gameplay in a SwiftUI project.

## Control Flow & Object Hierarchy

| 🐙 |
| :-: |
|📲 `AppDelegate` + `SceneDelegate`|
|↓|
|🎬 `YourGameCoordinator: OKGameCoordinator` ¹|
|↓|
|🚦 `YourGameState: OKGameState` ²|
|↕|
|🎛 `YourUI: SwiftUI.View` ³|
|🏞 `YourScene: OKScene` ³|
|↓|
|👾 `OKEntity` ⁴|
|↓|
|🚥 `YourEntityState: OKEntityState` ⁵|
|↕|
|🧩 `YourComponent: OKComponent` ⁶|
|↑|
|⛓ `OKComponentSystem` ⁷|

> ¹ `OKGameCoordinator` must be initialized before any other OctopusKit objects.

> ² Every game must have at least one `OKGameState`.

> ³ `SwiftUI` presents a UI overlay on top of the `OKScene` gameplay. UI controls or the scene may tell the game coordinator to enter different states and transition to other scenes. A scene itself is also represented by an entity which may have components of its own. A scene may be comprised entirely of components only, and need not necessarily have sub-entities.  

> ⁴ `OKEntity` is optional; a simple scene may directly add sprites and other child nodes to itself.

> ⁵ `OKEntityState` is optional. An entity need not necessarily have states.  

> ⁶ `OKComponent` may tell its entity to enter a different state, and it can also signal the scene to remove/spawn entities.  

> ⁷ `OKComponentSystem` is used by scenes to group each type of component in an ordered array which determines the sequence of component execution for every frame update cycle.

The objects that actually present your game on screen:

| SwiftUI View Hierarchy |
| :-: |
|📲 `AppDelegate` + `SceneDelegate` |
|↓|
|📦 `OKContainerView`|
|↓|
|🎛 `OKUIOverlay`|
|📦 `OKViewControllerRepresentable`|
|↓|
|🎥 `OKViewController` ¹|
|↓|
|🎥 `SpriteKit.SKView`|

*or*

| AppKit / UIKit Storyboard / XIB |
| :-: |
|📲 `AppDelegate` + `SceneDelegate` |
|↓|
|📦 `Main.storyboard`|
|↓|
|🎥 `OKViewController` ¹|
|↓|
|🎥 `SpriteKit.SKView`|

> ¹ `OKViewController` displays the `OKGameCoordinator.currentScene` and may be subclassed for custom game-specific presentation management.

## Game Coordinator and Game States

🎬 `OKGameCoordinator:`[`GKStateMachine`](https://developer.apple.com/documentation/gameplaykit/gkstatemachine)  
🚦 `OKGameState:`[`GKState`](https://developer.apple.com/documentation/gameplaykit/gkstate)

- At launch, the application configures a **Game Coordinator** object (which counts as a "controller" in the [MVC][mvc] hierarchy). The coordinator is a **State Machine** with one or more **Game States**, each associated with a **SpriteKit Scene** and a **SwiftUI** view. The coordinator may also manage global objects that are shared across states and scenes, i.e. the "model" of the game, such as the game world's map, player stats, multiplayer network sessions and so on.  

- `OKGameCoordinator` need not always be subclassed; projects that do not require a custom coordinator may simply use `OKGameCoordinator(states:initialStateClass:)`.

- The coordinator must be provided to the `OctopusKit(gameCoordinator:)` initializer and set your SwiftUI view hierarchy's top-level `.environmentObject`, to make it accessible to all game objects.

- `OKGameState` need not be subclassed if your game will have only one state and one scene; you may simply pass `OKGameState(associatedSceneClass: YourScene.self)` to the game coordinator initializer.

	> *Advanced: Although OctopusKit does not support this out of the box, a single application may contain multiple "games" by using multiple game coordinators, each with its own hierarchy of states and scenes.*
    
## Scenes

🏞 `OKScene:`[`SKScene`](https://developer.apple.com/documentation/spritekit/skscene)

- A **Scene** presents the visuals, plays audio, and receives player input events and device updates for each state or "act" of the game. A scene is itself an **Entity** with various **Components**, and it loads or creates sub-entities that represent the characters and other elements of the gameplay. 

    > A single scene may represent multiple game states.  
    > e.g. for most games, it may not be necessary to have a separate scene for a "Paused" game state, and a single scene may handle both "Play" and "Paused" game states by displaying a dark overlay and some text in the paused state.

- Once a scene is presented on screen, the system calls the `OKScene.update(_:)` method at the beginning of every frame, which goes through the list of the scene's **Component Systems** and updates all the **Components** in each system. 

- The update method then calls the `shouldUpdateGameCoordinator(deltaTime:)` and `shouldUpdateSystems(deltaTime:)` methods. The default implementation of these methods just checks all the paused flags, and returns true if none of those flags are set.

- OctopusKit handles all the boilerplate per-frame logic, like timer calculations, frame counts, entity management and pause/unpause behavior. This saves you from writing a lot of identical code for every scene, while still offering a customization point for subclasses of `OKScene` that have custom pause/unpause behavior or need to perform other per-frame logic.
 
    > See Apple's documentation for an overview of the [SpriteKit frame cycle][frame-cycle].

🌠 `OKSubscene:`[`SKNode`](https://developer.apple.com/documentation/spritekit/sknode)

- A **Subscene** is a node which may be added to a scene, but maintains its own hierarchy of entities and components. When a subscene is presented, the scene sets a special flag to pause the entities in the scene itself and any previous subscenes. This allows subscenes to be used for modal content which must be overlaid on top of the scene's content, while pausing the main action without pausing the engine, so that only the topmost subscene will be updated.

    > e.g. In an adventure game a subscene may be used to present a "cutscene" which shows an story event while pausing the gameplay.
    
> TODO: OKScene API overview

### Scenes should:

- Try to encapsulate as much of their content into components, including visual content as well as non-visual functionality, such as music and input subsystems.

## User Interface 

🎛 `YourGameStateUI:`[`SwiftUI.View`](https://developer.apple.com/documentation/swiftui)

- Every game state may optionally have an associated SwiftUI view that is displayed over the gameplay scene. SwiftUI lets you easily and quickly create complex user interfaces with a declarative syntax. Fluid animations, crisp text with advanced formatting, vector shapes, live previews and over 1,500 high-quality icons from Apple's [SF Symbols.][sf-symbols]

- Multiple states can share the same SwiftUI view, and a SwiftUI view may include the UI of other states as child views or `.background` or `.overlay`, thanks to the power of SwiftUI's composability.

- Through the `OKGameCoordinator` which is passed as an `environmentObject`, SwiftUI views can inspect and modify the state of your game. An `OKComponent` may adopt the `ObservableObject` protocol to provide automatic data-driven updates for labels and HUD elements.
 
## Entities

👾 `OKEntity:`[`GKEntity`](https://developer.apple.com/documentation/gameplaykit/gkentity)  
🚥 `OKEntityState:`[`GKState`](https://developer.apple.com/documentation/gameplaykit/gkstate)

- An **Entity** is a group of **Components** that may interact with each other. It may also have an **Entity State Machine** which is a special component comprising different **Entity States**. Each state has logic that decides which components to add to the entity and which components to remove depending on different conditions, as well as when to transition to a different state.

	> e.g. A *GrueEntity* with a *SleepingState, HuntingState, EatingState and DeadState.*

- `OKEntity` need not always be subclassed; `OKEntity(components:)` should be enough for most cases.

- Contain components which are the primary block of game functionality.

- May dynamically add or remove components during runtime, mutating themselves and taking on new behaviors.

- Have a delegate (which is by default the scene they're added to) to assist components with spawning new entities and removing themselves from their scene.

- May be subclassed from `OKEntity` and offer `init` constructors that group sets of related components. The components may be customized according to the supplied arguments.

	> e.g. A *PlayerShipEntity* with "mass", "speed" etc. parameters.

- Contain `StateMachineComponent`s that add and remove groups of components to the entity depending on the state.
    
    > e.g. A player character in a *SpawningState* may have a *BlinkingEffectComponent* but no *DamageComponent* as it must be invulnerable before it has fully spawned, but entering the *ReadyState* will add a *DamageComponent* as well as a *PlayerControlComponent* etc.

### The Scene Entity

- Every SpriteKit node has an optional `entity?` property. Since a scene also ultimately inherits from `SKNode`, it may also have an entity associated with it.

- The `OKScene.entity?` property is initialized with a `NodeComponent` and `SceneComponent` to represent the top of the node tree.

- Other components may be added directly to the scene entity to represent elements such as background layers, HUD overlays, other high-level visual features or abstract logic that acts upon the scene as a whole.

    > Very simple games may only consist of components which are added to the scene entity, without any "sub-entities."

### The Game Coordinator Entity

- `OKGameCoordinator` also has an `entity` property (not optional) which is initialized when the game is launched and is accessible from every scene.

- Games which need to share data or logic across multiple states and scenes can add persistent components to the game coordinator entity.

### Entities should *not:*

- Be subclassed too much, i.e. inherited from a subclass of `OKEntity`. Do not fall into the traps of inheritance, which may defeat the advantages of composition that components are supposed to offer.

- Contain properties or code other than initializers/constructors.

> TODO: OKEntity API overview

## Components

🧩 `OKComponent:`[`GKComponent`](https://developer.apple.com/documentation/gameplaykit/gkcomponent)  

- A **Component** represents each onscreen object or unit of game logic. It may contain properties and execute logic at specific moments in its lifetime: when it's added to an entity, removed from an entity, and/or once every frame. A component may signal its entity to enter a different state, or request the entity's scene to spawn new entities, or even to remove the component's own entity from the scene. 

    > Components may also access the game coordinator and its states. Nothing is "off limits" to a component; what a component may do is up to you. However, good practices dictate that a component should be polite and only access its own entity and its co-components.

⛓ `OKComponentSystem:`[`GKComponentSystem`](https://developer.apple.com/documentation/gameplaykit/gkcomponentsystem)

- Whenever a component is added to an entity, the scene registers the component with a **Component System** that matches the component's class. Only components that perform any logic during frame updates need to be registered with a system.

- After enumerating all components from all entities and adding them to a list of **Component Systems**, the scene updates each system in a deterministic order during the `OKScene.update(_:)` method every frame. The array of systems should be arranged such that components which depend on other components are processed after their dependencies.

	> e.g. An entity's `TouchControlledPositioningComponent` must be executed after its `TouchEventComponent`, so a scene's component systems array should place the system for `TouchEventComponent`s before the system for `TouchControlledPositioningComponent`s.

- Over the course of the gameplay, a scene, state or even a component may signal the **Game Coordinator** to enter a different **Game State** in response to certain game-specific conditions. The current game state's logic determines whether the transition is valid; if it is, the state then passes control to another state, which may then load a different scene.

    > As noted above, a single scene may choose to handle multiple game states. In those cases, no scene transition occurs during a game state transition. 

- Ideally, components should have no methods/callbacks triggered by events, delegation or notifications. If a component needs to process events, then a parent object, such as a scene or view controller, should create a separate component for holding copies of events every frame. Components that rely on events should read that event-holding component every frame. An example would be an input events component.

- SpriteKit and GameplayKit features should be abstracted behind and accessed via components as much as conveniently and practically possible.
	
	> e.g. access an `SKSpriteNode`'s `physicsBody` through a `PhysicsComponent`, instead of an `NodeComponent`'s node. This way, when the `PhysicsComponent` is removed from an entity, it marks the entity as no longer affected by physics.

- A component's properties can be supplied upon initialization and should generally be accessible afterwards.

- A component may depend upon other components of its entity, and it may provide the list of its co-dependencies/requirements as a property.

- Since components may be dynamically added to and removed from an entity, a component should query its entity for any required co-components whenever they are needed, e.g. on every frame update. Instead of raising exceptions or halting the app, a component should simply skip part or all of its functionality (optionally logging a warning) if any dependencies are unavailable.

- Dependencies should not be hardcoded or supplied in an init, unless they are "global" components, such as components of the scene's entity that process player input.

### Component Categories

A component may be conceptually classified under one or more of the following categories:

- **Data Component**: Adds some properties to the entity that other components may access and act upon.

	> e.g. A *PlayerInfoComponent* with *name* and *score* properties.

- **Visual Component**: A component that modifies the appearance of the SpriteKit node associated with its entity, or adds child nodes to it.

	> e.g. A *SpinComponent* that sets a sprite's color to green when added to the entity, changes the node's rotation in every frame, and sets the sprite's color to red when removed from the entity, or a *ThrustersEffectComponent* which draws a jet flame behind a spaceship.

- **Logic Component**: Executes some code every frame or at specific moments during an entity's lifetime: when added to the entity, upon being removed from an entity, or in response to external/asynchronous events such as player input.

    > e.g. A `TimeComponent` that keeps track of the seconds that have elapsed since the component was added to an entity.
    
    > Components such as these, which execute some logic in every frame, must be added to a component system or updated manually in a scene's `shouldUpdateSystems(deltaTime:)` method, otherwise they cannot perform their task.

- **Coordinator Component**: A logic component that observes one or more components and uses that information to act upon other components.

    > e.g. A *PlayerInfoDisplayComponent* which is added to a scene, that searches the scene for an entity with a *PlayerInfoComponent*, and uses the properties of that data component to update the scene's *HUDComponent*.
    
    > Such a design lets the *HUDComponent* remain a visual component which focuses on managing its graphics and labels, while letting other components decide what to display in the HUD, which may be player info, enemy info, or temporary alerts etc.
		
- **Support/Utility Component**: Performs no action upon the entity on its own, but provides a set of methods and data to assist other components.

	> e.g. A `TextureDictionaryComponent` used by a `TextureAnimationComponent`, and a `TouchEventComponent` used by many touch-controlled components.
		
### Components should:

- Be broken into sub-components if one component handles many duties.
    
	> e.g. a `PlayerControlComponent` may be broken down into a `TouchControlledSeekingComponent` and a `MotionControlledThrustComponent`.

### What should be Entities and what should be Components?

- A spaceship, or a monster, are not components; they are entities. A spaceship may have a *ThrusterComponent*, and a *GunComponent*. A monster may have a *MonsterSpeciesComponent*. Both will have a `NodeComponent`, `PhysicsComponent` etc.

> TODO: OKComponent API overview

## State Machines

> TODO: Incomplete section  
> TODO: OKGameState/OKEntityState API overview

- If an entity can be in one of several conceptual states at a given time, it more makes sense to represent those states with a `GKStateMachine` (as encapsulated by a `StateMachineComponent`) instead of putting lots of conditional checks in multiple components.

	> e.g. A spaceship entity may have gun components that generate heat and temporarily stop firing when they are overheated. Without states, you might need to repeatedly check for the overheated state in *GunComponent* and *GunControlComponent* and *ShipVisualEffectsComponent* etc. With states, you may have an *OverheatedState* that removes the *GunControlComponent* and adds a *OverheatedVisualEffectComponent*. The overheated state monitors the *HeatComponent* to see when the ship cools down, and transitions the entity back to its *NormalState* which restores the relevant components necessary for normal player control.

### State classes should:

- Only handle the logic of when and whether to transition to a different state.

## Further Reading

For details on the non-OctopusKit-specific concepts used here, see Apple's documentation and Wikipedia:

* [Entity-Component-System][ecs]
* [Model-View-Controller][mvc]
* [Composition Over Inheritance][composition-over-inheritance]
* [SpriteKit Frame Update Cycle][frame-cycle]

----

[OctopusKit][repository] © 2021 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[quickstart]: https://github.com/InvadingOctopus/octopuskit/blob/master/QuickStart/README%20QuickStart.md
[guide]: https://invadingoctopus.io/octopuskit/documentation/guide.html
[tutorials]: https://invadingoctopus.io/octopuskit/documentation/tutorials.html
[tips]: https://invadingoctopus.io/octopuskit/documentation/tips.html
[conventions-&-design]: https://invadingoctopus.io/octopuskit/documentation/conventions.html
[todo]: https://invadingoctopus.io/octopuskit/documentation/todo.html

[mvc]: https://en.wikipedia.org/wiki/Model–view–controller
[composition-over-inheritance]: https://en.wikipedia.org/wiki/Composition_over_inheritance
[ecs]: https://en.wikipedia.org/wiki/Entity_component_system
[reducing-dynamic-dispatch]: https://developer.apple.com/swift/blog/?id=27
[frame-cycle]: https://developer.apple.com/documentation/spritekit/skscene/responding_to_frame-cycle_events
[sf-symbols]: https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/
