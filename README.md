# SF Symbols Generator

- [Declaration](#declaration)
- [Usage](#usage)
  - [Type-Safe](#type-safe)
- [Installation](#installation)
  - [Swift Package Manager (SPM)](#swift-package-manager-spm)
  - [Xcode](#xcode)

A Swift macro generating type-safe SF Symbols

## Declaration

```swift
@freestanding(declaration, names: named(SFSymbol)) macro SFSymbol(accessLevel: AccessLevel = .internal, names: [String])

enum AccessLevel {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
}
```

## Usage

Source code:

```swift
import SFSymbolsGenerator
import SwiftUI

// Default AccessLevel is `.internal`
#SFSymbol(accessLevel: .public, names: [
    "star",
    "case",
    "star.square.on.square",
])
```

Expanded source:

```swift
public enum SFSymbol: String {
    case star
    case `case`
    case starSquareOnSquare = "star.square.on.square"

    public var name: String {
        self.rawValue
    }

    @available(iOS 13.0, *)
    @available(macCatalyst 13.0, *)
    @available(macOS 11.0, *)
    @available(tvOS 13.0, *)
    @available(watchOS 6.0, *)
    public func image() -> Image {
        Image(systemName: self.rawValue)
    }

    @available(iOS 16.0, *)
    @available(macCatalyst 16.0, *)
    @available(macOS 13.0, *)
    @available(tvOS 16.0, *)
    @available(watchOS 9.0, *)
    public func image(variableValue: Double?) -> Image {
        Image(systemName: self.rawValue, variableValue: variableValue)
    }

    #if canImport (UIKit)
    @available(iOS 13.0, *)
    @available(macCatalyst 13.0, *)
    @available(tvOS 13.0, *)
    @available(watchOS 6.0, *)
    public func uiImage() -> UIImage {
        UIImage(systemName: self.rawValue)!
    }

    @available(iOS 13.0, *)
    @available(macCatalyst 13.1, *)
    @available(tvOS 13.0, *)
    @available(watchOS 6.0, *)
    public func uiImage(withConfiguration configuration: UIImage.Configuration?) -> UIImage {
        UIImage(systemName: self.rawValue, withConfiguration: configuration)!
    }

    @available(iOS 16.0, *)
    @available(macCatalyst 16.0, *)
    @available(tvOS 16.0, *)
    @available(watchOS 9.0, *)
    public func uiImage(variableValue: Double, configuration: UIImage.Configuration? = nil) -> UIImage {
        UIImage(systemName: self.rawValue, variableValue: variableValue, configuration: configuration)!
    }

    @available(iOS 13.0, *)
    @available(macCatalyst 13.1, *)
    @available(tvOS 13.0, *)
    public func uiImage(compatibleWith traitCollection: UITraitCollection?) -> UIImage {
        UIImage(systemName: self.rawValue, compatibleWith: traitCollection)!
    }
    #else
    @available(macOS 11.0, *)
    public func nsImage(accessibilityDescription description: String) -> NSImage {
        NSImage(systemSymbolName: self.rawValue, accessibilityDescription: description)!
    }

    @available(macOS 13.0, *)
    public func nsImage(variableValue value: Double, accessibilityDescription description: String?) -> NSImage {
        NSImage(systemSymbolName: self.rawValue, variableValue: value, accessibilityDescription: description)!
    }
    #endif
}
```

### Type-Safe

Checks validity:

<img width="661" alt="Valid" src="https://github.com/zijievv/sf-symbols-generator/assets/48703581/33b8d7de-6694-4cfe-bb3e-041c1887e515">

---

<img width="652" alt="Empty" src="https://github.com/zijievv/sf-symbols-generator/assets/48703581/22245e74-7a6a-417a-ac45-63aa21d9bd0f">

---

<img width="534" alt="Screenshot 2023-07-23 at 13 26 20" src="https://github.com/zijievv/sf-symbols-generator/assets/48703581/f26dec82-b1d7-479d-8592-7b7dcdec9936">

## Installation

### [Swift Package Manager](https://www.swift.org/package-manager/) (SPM)

Add the following line to the dependencies in `Package.swift`, to use the `SFSymbol` macro in a SPM project:

```swift
.package(url: "https://github.com/zijievv/sf-symbols-generator", from: "1.1.0"),
```

In your target:

```swift
.target(name: "<TARGET_NAME>", dependencies: [
    .product(name: "SFSymbolsGenerator", package: "sf-symbols-generator"),
    // ...
]),
```

Add `import SFSymbolsGenerator` into your source code to use the `SFSymbol` macro.

### Xcode

Go to `File > Add Package Dependencies...` and paste the repo's URL:

```
https://github.com/zijievv/sf-symbols-generator
```
