---
permalink: documentation/todo.html
---

# OctopusKit Roadmap

> If you'd like to help with the development of the OK project, these are some of the areas that need to be implemented.

1. [Currently Working On](#currently-working-on)
2. [Major Missing Features](#major-missing-features)
3. [To Do](#to-do)
4. [To Decide](#to-decide)

## Currently Working On

- [Swift Logging API](https://github.com/apple/swift-log)

## Major Missing Features

*More-or-less in order of priority/necessity:*

- Components for gamepad/joystick and Siri Remote input.
- Asset/resource loading system.
- Saving and loading game/scene/entity/component graphs via `Codable`.
- Networking components.
- SceneKit support.
- Declarative syntax like SwiftUI for describing scenes and entities. 🤫
- Custom Scene Editor & Live Previews?

## To Do

- More Tests. Too lazy.
- Decide upon a coding style and conventions.
- More tutorials for common tasks.
- Clarify `super` chaining where applicable – when an overridden method in a subclass *needs* to call the superclass method for the functionality to work correctly – and enforce it when it becomes possible through language support in a future version of Swift, similar to `NS_REQUIRES_SUPER` in Objective-C.
- Eliminate the possibility of a `SKNode.physicsBody` being added to a scene more than once.
- Internationalization/Localization
- Implement configurable Xcode templates (single files with multiple variations based on options during file creation, e.g. single-state scenes vs. multi-state scenes.) 
- Add `Codable` support for components and their `init?(coder aDecoder: NSCoder)` where applicable.
- GitHub Wiki?

### Performance Optimizations

- Replace `Array` with `ContiguousArray` where applicable.

## Outstanding Bugs & Known Issues 

- Nodes added via an `SKReferenceNode` that is loaded from a scene created in the Xcode Scene Editor, start with their `isPaused` set to `true` until Xcode pauses and resumes the program execution.

- `UITouch.location(in:)` and `UITouch.previousLocation(in:)` are sometimes not updated for many frames, causing a node to "jump" many pixels after 10 or so frames. Same issue with `preciseLocation(in:)` and `precisePreviousLocation(in:)`.

- `UITouch.location(in:)` and `UITouch.preciseLocation(in:)` for a touch "wobbles" when a 2nd touch moves near it, even if the tracked touch is stationary. Seems to be a problem since iOS 11.3 on all devices, in all apps, including system apps like Photos. RADAR: 39997859.

## To Decide

- Use variadic parameters (`...`) instead of arrays in certain places, like `GKEntity.addComponent(_:)`?
- Write standalone documentation for every API unit? (Currently, source comments are the primary API documentation.)
- Write documentation and tutorials for absolute beginners? i.e. people who have no experience with Xcode or Swift?
- Rework pausing/subscene system?

----

[OctopusKit][repository] © 2021 [Invading Octopus][website] • [Apache License 2.0][license]

[repository]: https://github.com/invadingoctopus/octopuskit
[website]: https://invadingoctopus.io
[license]: https://www.apache.org/licenses/LICENSE-2.0.html
