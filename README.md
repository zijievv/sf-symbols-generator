# SF Symbols Generator

- [Usage](#usage)
  - [Type-Safe](#type-safe)
- [Installation](#installation)
  - [Swift Package Manager (SPM)](#swift-package-manager-spm)
  - [Xcode](#xcode)

A Swift macro generating type-safe SF Symbols

## Usage

Source code:

```swift
import SFSymbolsGenerator
import SwiftUI

#SFSymbol(names: [
    "star",
    "star.fill",
    "star.square.on.square",
])
```

Expanded source:

```swift
enum SFSymbol: String {
    case star
    case starFill = "star.fill"
    case starSquareOnSquare = "star.square.on.square"

    var name: String {
        self.rawValue
    }

    func image() -> Image {
        Image(systemName: self.rawValue)
    }

    func image(variableValue: Double?) -> Image {
        Image(systemName: self.rawValue, variableValue: variableValue)
    }

    #if canImport(UIKit)
    func uiImage() -> UIImage {
        UIImage(systemName: self.rawValue)!
    }

    func uiImage(withConfiguration configuration: UIImage.Configuration?) -> UIImage {
        UIImage(systemName: self.rawValue, withConfiguration: configuration)!
    }

    func uiImage(variableValue: Double, configuration: UIImage.Configuration? = nil) -> UIImage {
        UIImage(systemName: self.rawValue, variableValue: variableValue, configuration: configuration)!
    }

    func uiImage(compatibleWith traitCollection: UITraitCollection?) -> UIImage {
        UIImage(systemName: self.rawValue, compatibleWith: traitCollection)!
    }
    #else
    func nsImage(accessibilityDescription description: String) -> NSImage {
        NSImage(systemSymbolName: self.rawValue, accessibilityDescription: description)!
    }

    func nsImage(variableValue value: Double, accessibilityDescription description: String?) -> NSImage {
        NSImage(systemSymbolName: self.rawValue, variableValue: value, accessibilityDescription: description)!
    }
    #endif
}
```

### Type-Safe

Checks validity

<img width="661" alt="Valid" src="https://github.com/zijievv/sf-symbols-generator/assets/48703581/33b8d7de-6694-4cfe-bb3e-041c1887e515">

---

<img width="652" alt="Empty" src="https://github.com/zijievv/sf-symbols-generator/assets/48703581/22245e74-7a6a-417a-ac45-63aa21d9bd0f">

---

<img width="534" alt="Screenshot 2023-07-23 at 13 26 20" src="https://github.com/zijievv/sf-symbols-generator/assets/48703581/f26dec82-b1d7-479d-8592-7b7dcdec9936">

## Installation

### [Swift Package Manager](https://www.swift.org/package-manager/) (SPM)

Add the following line to the dependencies in `Package.swift`, to use the `SFSymbol` macro in a SPM project:

```swift
.package(url: "https://github.com/zijievv/sf-symbols-generator", from: "0.1.0"),
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
