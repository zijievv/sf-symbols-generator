import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SFSymbolsGeneratorMacros

let testMacros: [String: Macro.Type] = [
    "SFSymbol": SFSymbolMacro.self,
]

final class SFSymbolsGeneratorTests: XCTestCase {
    let starStr = "star"
    let starFillStr = "star.fill"

    func arrayExprStr() -> String {
        """
["\(starStr)", "\(starFillStr)", "star.square.on.square"]
"""
    }

    func testMacro() {
        assertMacroExpansion(
            """
#SFSymbol(names: \(arrayExprStr()))
""",
            expandedSource: """
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
""",
            macros: testMacros
        )
    }
}
