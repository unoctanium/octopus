---
permalink: documentation/guide.html
redirect_from: "/Documentation/Usage%2Guide.html"
---

# OctopusKit Usage Guide

### Tutorials and examples for common tasks

1. [Adding OctopusKit to your project](#adding-octopuskit-to-your-project)
2. [Xcode File Templates](#xcode-file-templates)
3. [Player Input](#player-input)
4. [Logs](#logs)
5. [Sharing Data](#sharing-data)
6. [Accessing Game State from SwiftUI Views](#accessing-game-state-from-swiftui-views)
7. [Physics Collisions & Contact Detection](#physics-collisions)
8. [Advanced Stuff](#advanced-stuff)

##### Related Documentation

* [OctopusKit Architecture][architecture]
* [Tips & Troubleshooting][tips]

##### Notes

* This documentation assumes that the reader is using OctopusKit in a SwiftUI project, and has some prior experience with developing for Apple platforms in the Swift programming language.

* Currently, API documentation (i.e. for types/methods/properties) is only provided via extensive source-code comments, which can be viewed in Xcode's Quick Help.

    > This guide provides examples for common tasks and how to get started, but there is no standalone reference for the API, as I don't have the time and energy to write that alongside developing the engine. (´･_･`)  
    >
    > The best way to learn may be to examine the engine source code.
        
## Adding OctopusKit to your project

### 🍰 **To begin from a template**:

1. See one of the following files in the OctopusKit package/repository:

    * [**README QuickStart.md**][quickstart] in the `QuickStart` folder.

    * [**README Template.md**][template] in the `Templates/Game` folder.

### 🛠 **To import OctopusKit into a new or existing project:**

1. 📦 Add OctopusKit as a **Swift Package Manager** Dependency.
    
    > *Xcode File menu » Swift Packages » Add Package Dependency...*
        
    > Enter the URL for the GitHub [repository][repository]. Download the "develop" branch for the latest version.
    
2. Create an instance of `OKGameCoordinator`.

    ```
    let gameCoordinator = OKGameCoordinator(
        states: [OKGameState()], // A placeholder for now.
        initialStateClass: OKGameState.self)
    ```

    > The game coordinator is the top-level "controller" (in the Model-View-Controller sense) that manages the global state of your game.
    
    > If your game needs to share complex logic or data across multiple scenes, you may create a subclass of `OKGameCoordinator`.

    > **SwiftUI (iOS/iPadOS, macOS, tvOS):** You may use `@StateObject var gameCoordinator` as an instance variable of `ContentView` if you do not require it to be a global value. The `@StateObject` property wrapper ensures that the coordinator is not recreated whenever the view hierarchy is updated.
 
3. Presenting OctopusKit content in your view hierarchy requires different steps depending on whether you use SwiftUI or AppKit/UIKit:

    * **SwiftUI (iOS/iPadOS, macOS, tvOS):** Add a `OKContainerView` and pass the game coordinator as an `environmentObject` to it:
    
        ```
        import OctopusKit
    
        struct ContentView: View {
            var body: some View {
                OKContainerView()
                    .environmentObject(gameCoordinator)
            }
        }
        ```
        
        > The `OKContainerView` combines a SpriteKit `SKView` with a SwiftUI overlay.
        
        > ❗️ If you created a subclass of `OKGameCoordinator`, then you must provide a generic type parameter: `OKContainerView<MyGameCoordinator>()`
    
        > 💡 It's best to pass the game coordinator `environmentObject` to the top level content view created in the `SceneDelegate.swift` file, which will make it available to your entire view hierarchy.
    
    * **AppKit (macOS) or UIKit (iOS/iPadOS, tvOS):** Your storyboard should have an `SKView` whose controller class is set to `OKViewController` or its subclass.
        
        * If you use `OKViewController` directly, then you must initialize OctopusKit early in your application launch cycle: 

            ```
            func application(_ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
            {
                try! OctopusKit(gameCoordinator: coordinator)
                return true
            }
            ```
        
        * If you create your own subclass, it must implement these initializers:
    
            ```
            required init?(coder aDecoder: NSCoder) {
                try! OctopusKit(gameCoordinator: gameCoordinator)
                super.init(coder: aDecoder)
            }
            
            required init(gameCoordinator: OKGameCoordinator? = nil) {
                try! super.init(gameCoordinator: gameCoordinator)
            }
            ``` 
            
            > ❗️ If you are starting with Xcode's SpriteKit Game template, you must **delete** the `GameViewController.viewDidLoad()` override, as that will prevent the `OKViewController` from presenting your game coordinator's scenes.
        
4. Code the states, scenes and UI for your game. The game coordinator must have at least one state that is associated with a scene, so your project must have custom classes which inherit from `OKGameState` and `OKScene`. 

    > For an explanation of these classes, see the [Architecture][architecture] documentation.

    > If your scenes requires custom per-frame logic, you may override the `OKScene.shouldUpdateSystems(deltaTime:)` method.
    
    > If your game state classes also perform per-frame updates, then you may also override the `OKScene.shouldUpdateGameCoordinator(deltaTime:)` method.

5. Each of your game states can have a SwiftUI view associated with them to provide user interface elements like text and HUDs. The SwiftUI view is overlaid on top of the SpriteKit gameplay view. To let SwiftUI interact with your game's state, make sure to pass an `.environmentObject(gameCoordinator)` to your SwiftUI view hierarchy.

## Xcode File Templates

To save yourself from writing a lot of the same code for every new state, scene, component or method override, copy the contents of the `Templates/Xcode` subfolder of the OK package to your `~/Library/Developer/Xcode/Templates/OctopusKit`.

This offers a section of templates for OctopusKit when you create a ⌘N New File in Xcode, including a very convenient template for creating a new game state class + its scene + UI in a single file, with just one click.

💡 You may create a symbolic link (with the `ln` Terminal command) to keep the templates folders in sync whenever they're updated.

## Logs

OctopusKit uses the Xcode debug console to `print` many kinds of events and status messages. Reading the logs can be very helpful in understanding the control flow and debugging your game. Pay special attention to warnings about incorrect usage of APIs that may cause unexpected behavior. 

💡 Customize the logging system at the earliest point during application launch, e.g. in the `AppDelegate`'s `application(_:didFinishLaunchingWithOptions:)` method.

> Set the formatting to your preferences:

```swift
OKLog.printEmptyLineBetweenFrames
OKLog.printTextOnSecondLine
OKLog.printEmptyLineBetweenEntries
OKLog.printAsCSV
```

> Check `OctopusKit+Logs.swift` in `Sources/Core/Launch` to see the list of default logs. Disable unwanted logs to reduce clutter and improve performance:

```swift
OctopusKit.logForDebug.isDisabled = true
OctopusKit.logForTips.isDisabled  = true
```

💡 Set [Conditional Compilation Flags](tips#conditional-compilation-flags--debugging-aids) in [Tips & Troubleshooting][tips] to enable extra levels of verbose logging, such as player input events and physics collisions.

⚙️ Advanced: You may modify the `OKLog` and `OKLogEntry` code to emit entries for a different system, such as Apple's [Unified Logging (`os_log`)](https://developer.apple.com/documentation/os/logging) or [SwiftLog](https://github.com/apple/swift-log/).

## Player Input

In your **scene**'s `override func createContents()`

```swift
self.entity?.addComponents([
    
    // Collect asynchronous events in a buffer for processing them in sync with the frame-update cycle:
    sharedMouseOrTouchEventComponent,   // iOS & macOS
    
    // Translate mouse or touch input to an OS-agnostic format:
    sharedPointerEventComponent,        // iOS & macOS
    
    sharedKeyboardEventComponent        // macOS
    ])
    
yourPlayerEntity.addComponents([

    // Use the scene's shared event stream:
    RelayComponent(for: sharedPointerEventComponent),
    
    // Filter the stream for events in the entity's sprite's bounds:
    NodePointerStateComponent(),
    
    PointerControlledDraggingComponent()
    ])
```

💡 See other components in `OctopusKit/Components/Input`

## Sharing Data

You can share data between states, scenes and entities in many ways.

You may simply add custom properties to `OctopusKit.shared.gameCoordinator`

Or use data components like a `DictionaryComponent`

```swift
OctopusKit.shared.gameCoordinator.entity.addComponent(
    DictionaryComponent <String, Any> ([
        "playerNode":  playerEntity.node as Any,
        "playerStats": playerEntity[PlayerStatsComponent.self] as Any ]) )
```

To access that data:

```swift
if  let globalData = OctopusKit.shared.gameCoordinator.entity[DictionaryComponent<String, Any>.self] {
    
    let node  = globalData["playerNode"]  as? SKNode
    let stats = globalData["playerStats"] as? PlayerStatsComponent
    //  ...
}
```

❕ Note that once an object is added to the dictionary, it holds a reference to the object.

💡 Instead of typo-prone `String` keys, use `TypeSafeIdentifiers`

## Accessing Game State from SwiftUI Views

```swift
class DataComponent: OKComponent, ObservableObject {
    
    @Published public var secondsElapsed: TimeInterval = 0
    
    override func update(deltaTime seconds: TimeInterval) {
        secondsElapsed += seconds
    }
}

struct DataComponentLabel: View {

    @ObservedObject var component: DataComponent
    
    var body: some View {
        Text("Seconds elapsed: \(component.secondsElapsed)")
    }
}
```

In a container view, pass the component as an argument to the label view:

```swift
var globalDataComponent: DataComponent? {
    gameCoordinator.entity[DataComponent.self]
}

var body: some View {
    if  globalDataComponent != nil {
        DataComponentLabel(component: globalDataComponent!)
    }
}
```

💡 You may write a custom property wrapper like say `@Component` to simplify accessing components from the current scene etc.

## Physics Collisions

```swift
scene.entity?.addComponents([PhysicsWorldComponent(),
                            sharedPhysicsEventComponent])

scene.componentSystems.createSystem(forClass: PlayerContactComponent.self)
```

```swift
class PlayerContactComponent: PhysicsContactComponent {
    
    override func didBegin(_ contact: SKPhysicsContact, in scene: OKScene?) {
       // Handle the collision.
    }
}
```

```swift
extension PhysicsCategories {
    static let player       = PhysicsCategories(1 << 0)
    static let enemy        = PhysicsCategories(1 << 1)
    static let projectile   = PhysicsCategories(1 << 2)
}
```

```swift
playerPhysicsBody
    .categoryBitMask    (.player)
    .collisionBitMask   (.enemy)
    .contactTestBitMask ([.enemy, .projectile])
    
playerEntity.addComponents([PhysicsComponent(physicsBody: playerPhysicsBody),
                            RelayComponent(for: scene.sharedPhysicsEventComponent),
                            PlayerContactComponent())

```

* A `PhysicsEventComponent` is like a `TouchEventComponent`; it makes more sense to create just one and add it to the scene's root entity, then share it with child entities via `RelayComponents`.  
Every `OKScene` has a `sharedPhysicsEventComponent` property. Your child entities can access it with a `RelayComponent(for: scene.sharedPhysicsEventComponent)`.

* A `PhysicsContactComponent` of an entity checks the `PhysicsEventComponent` of the scene (via a relay) during its `update(deltaTime:)` method, and looks for events which involve the `PhysicsComponent` body of its entity.

* If an entity's physics body is involved in a contact event, then that entity's `PhysicsContactComponent` calls its `didBegin(_:in:)` or `didEnd(_:in:)` method, which are empty, abstract methods that must be customized by a game-specific subclass of `PhysicsContactComponent`.

* You must create a subclass of `PhysicsContactComponent`, for example a `MonsterContactComponent`, and add it to all monster entities (and of course, remember to create a component system for `MonsterContactComponent.self`).

* Your `PhysicsContactComponent` should override at least the `didBegin(_:in:)` method, and use it to decide what happens when a monster is involved in any physics collisions (after checking the arguments passed to that method to inspect the scene and other bodies).

> ❗️ Your scene's `physicsWorld.contactDelegate` property must be set to the scene itself, otherwise the scene's `PhysicsEventComponent` will not receive any events! (The property is set automatically when you add a `PhysicsWorldComponent` to the scene entity.)

> ❗️ Your physics bodies should have their `categoryBitMask`, `collisionBitMask` and `contactTestBitMask` properties set according to which other bodies they should interact with and report events for. See Apple's SpriteKit documentation for details.

> ❗️ `PhysicsEventComponent` and `PhysicsContactComponent` need to be updated every frame, so create component systems for them (and for their subclasses, if any)! Contact handling components must be updated *after* the `PhysicsEventComponent` component, so be mindful of the order of component systems as well.

* 💡 Set the `LOGPHYSICS` custom compilation flag to see debugging information related to physics.

## Advanced Stuff

### Using the Xcode Scene Editor as the primary design tool 

> TODO: Incomplete section

Set the custom class of the scene as `OKScene` or a subclass of it. Load the scene by calling `OKGameCoordinator.loadAndPresentScene(fileNamed:withTransition:)`, e.g. during the `didEnter.from(_:)` event of an `OKGameState`. 

### Parallel Execution

You may be able to update multiple components simultaneously in parallel, if they do not depend upon each other and will not cause conflicts by accessing/modifying the same data.

For example, you may have multiple arrays of component systems with different dependency graphs, such as:

* `[MouseEventComponent, MouseControlledRotationComponent, MouseControlledShootingComponent]`
* `[KeyboardEventComponent, KeyboardControlledMovementComponent]`

If all these components are thread-safe, you could update those systems in parallel.

----

[OctopusKit][repository] © 2021 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html

[quickstart]: https://github.com/InvadingOctopus/octopuskit/blob/master/QuickStart/README%20QuickStart.md
[template]: https://github.com/InvadingOctopus/octopuskit/blob/master/Templates/Game/README%20Template.md
[architecture]: https://invadingoctopus.io/octopuskit/documentation/architecture.html
[tutorials]: https://invadingoctopus.io/octopuskit/documentation/tutorials.html
[tips]: https://invadingoctopus.io/octopuskit/documentation/tips.html
[conventions-&-design]: https://invadingoctopus.io/octopuskit/documentation/conventions.html
[todo]: https://invadingoctopus.io/octopuskit/documentation/todo.html
