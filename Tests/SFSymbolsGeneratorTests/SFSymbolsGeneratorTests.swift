import SFSymbolsGenerator
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SFSymbolsGeneratorMacros)
import SFSymbolsGeneratorMacros

let testMacros: [String: Macro.Type] = [
    "SFSymbol": SFSymbolMacro.self
]
#endif

final class SFSymbolsGeneratorTests: XCTestCase {
    let starStr = "star"
    let starFillStr = "star.fill"

    func arrayExprStr() -> String {
        """
        ["\(starStr)", "\(starFillStr)", "star.square.on.square"]
        """
    }

    func testMacro() {
        #if canImport(SFSymbolsGeneratorMacros)
        assertMacro("private")
        assertMacro("fileprivate")
        assertMacro("internal")
        assertMacro("public")
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func assertMacro(_ accessLevel: String) {
        assertMacroExpansion(source(accessLevel), expandedSource: expected(accessLevel), macros: testMacros)
    }

    func source(_ accessLevel: String) -> String {
        "#SFSymbol(accessLevel: .\(accessLevel), names: \(arrayExprStr()))"
    }

    func expected(_ accessLevel: String) -> String {
        let enumAccess: String = accessLevel == "internal" ? "" : "\(accessLevel) "
        let propertyAccess: String = accessLevel == "public" ? "\(accessLevel) " : ""
        return """
            \(enumAccess)enum SFSymbol: String {
                case star
                case starFill = "star.fill"
                case starSquareOnSquare = "star.square.on.square"

                \(propertyAccess)var name: String {
                    self.rawValue
                }

                @available(iOS 13.0, *)
                @available(macCatalyst 13.0, *)
                @available(macOS 11.0, *)
                @available(tvOS 13.0, *)
                @available(watchOS 6.0, *)
                \(propertyAccess)func image() -> Image {
                    Image(systemName: self.rawValue)
                }

                @available(iOS 16.0, *)
                @available(macCatalyst 16.0, *)
                @available(macOS 13.0, *)
                @available(tvOS 16.0, *)
                @available(watchOS 9.0, *)
                \(propertyAccess)func image(variableValue: Double?) -> Image {
                    Image(systemName: self.rawValue, variableValue: variableValue)
                }

                #if canImport (UIKit)
                @available(iOS 13.0, *)
                @available(macCatalyst 13.0, *)
                @available(tvOS 13.0, *)
                @available(watchOS 6.0, *)
                \(propertyAccess)func uiImage() -> UIImage {
                    UIImage(systemName: self.rawValue)!
                }

                @available(iOS 13.0, *)
                @available(macCatalyst 13.1, *)
                @available(tvOS 13.0, *)
                @available(watchOS 6.0, *)
                \(propertyAccess)func uiImage(withConfiguration configuration: UIImage.Configuration?) -> UIImage {
                    UIImage(systemName: self.rawValue, withConfiguration: configuration)!
                }

                @available(iOS 16.0, *)
                @available(macCatalyst 16.0, *)
                @available(tvOS 16.0, *)
                @available(watchOS 9.0, *)
                \(propertyAccess)func uiImage(variableValue: Double, configuration: UIImage.Configuration? = nil) -> UIImage {
                    UIImage(systemName: self.rawValue, variableValue: variableValue, configuration: configuration)!
                }

                @available(iOS 13.0, *)
                @available(macCatalyst 13.1, *)
                @available(tvOS 13.0, *)
                \(propertyAccess)func uiImage(compatibleWith traitCollection: UITraitCollection?) -> UIImage {
                    UIImage(systemName: self.rawValue, compatibleWith: traitCollection)!
                }
                #else
                @available(macOS 11.0, *)
                \(propertyAccess)func nsImage(accessibilityDescription description: String) -> NSImage {
                    NSImage(systemSymbolName: self.rawValue, accessibilityDescription: description)!
                }

                @available(macOS 13.0, *)
                \(propertyAccess)func nsImage(variableValue value: Double, accessibilityDescription description: String?) -> NSImage {
                    NSImage(systemSymbolName: self.rawValue, variableValue: value, accessibilityDescription: description)!
                }
                #endif
            }
            """
    }
}
