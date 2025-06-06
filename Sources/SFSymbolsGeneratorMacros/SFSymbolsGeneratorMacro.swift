import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftUI

public struct SFSymbolMacro: DeclarationMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let accessLevel: String
        let names: [String]
        switch node.arguments.count {
        case 0:
            accessLevel = internalAccess
            names = try sfSymbolNames(from: node.trailingClosure)
        case 1:
            if let trailingClosure = node.trailingClosure {
                accessLevel = try accessControl(from: node.arguments.first)
                names = try sfSymbolNames(from: trailingClosure)
            } else {
                accessLevel = internalAccess
                names = try sfSymbolNames(from: node.arguments.first)
            }
        case 2:
            accessLevel = try accessControl(from: node.arguments.first)
            names = try sfSymbolNames(from: node.arguments.last)
        default: return []
        }
        let enumAccess = accessLevel == internalAccess ? "" : "\(accessLevel) "
        let propertyAccess = accessLevel == publicAccess ? "\(publicAccess) " : ""
        let decl: DeclSyntax = """
            \(raw: enumAccess)enum SFSymbol: String {
                \(raw: names.map(caseExpression(name:)).joined(separator: "\n    "))

                \(raw: propertyAccess)var name: String { self.rawValue }

                @available(iOS 13.0, *)
                @available(macCatalyst 13.0, *)
                @available(macOS 11.0, *)
                @available(tvOS 13.0, *)
                @available(watchOS 6.0, *)
                \(raw: propertyAccess)func image() -> Image {
                    Image(systemName: self.rawValue)
                }

                @available(iOS 16.0, *)
                @available(macCatalyst 16.0, *)
                @available(macOS 13.0, *)
                @available(tvOS 16.0, *)
                @available(watchOS 9.0, *)
                \(raw: propertyAccess)func image(variableValue: Double?) -> Image {
                    Image(systemName: self.rawValue, variableValue: variableValue)
                }

                #if canImport (UIKit)
                @available(iOS 13.0, *)
                @available(macCatalyst 13.0, *)
                @available(tvOS 13.0, *)
                @available(watchOS 6.0, *)
                \(raw: propertyAccess)func uiImage() -> UIImage {
                    UIImage(systemName: self.rawValue)!
                }

                @available(iOS 13.0, *)
                @available(macCatalyst 13.1, *)
                @available(tvOS 13.0, *)
                @available(watchOS 6.0, *)
                \(raw: propertyAccess)func uiImage(withConfiguration configuration: UIImage.Configuration?) -> UIImage {
                    UIImage(systemName: self.rawValue, withConfiguration: configuration)!
                }

                @available(iOS 16.0, *)
                @available(macCatalyst 16.0, *)
                @available(tvOS 16.0, *)
                @available(watchOS 9.0, *)
                \(raw: propertyAccess)func uiImage(variableValue: Double, configuration: UIImage.Configuration? = nil) -> UIImage {
                    UIImage(systemName: self.rawValue, variableValue: variableValue, configuration: configuration)!
                }

                @available(iOS 13.0, *)
                @available(macCatalyst 13.1, *)
                @available(tvOS 13.0, *)
                \(raw: propertyAccess)func uiImage(compatibleWith traitCollection: UITraitCollection?) -> UIImage {
                    UIImage(systemName: self.rawValue, compatibleWith: traitCollection)!
                }
                #endif
                #if canImport (AppKit)
                @available(macOS 11.0, *)
                \(raw: propertyAccess)func nsImage(accessibilityDescription description: String) -> NSImage {
                    NSImage(systemSymbolName: self.rawValue, accessibilityDescription: description)!
                }

                @available(macOS 13.0, *)
                \(raw: propertyAccess)func nsImage(variableValue value: Double, accessibilityDescription description: String?) -> NSImage {
                    NSImage(systemSymbolName: self.rawValue, variableValue: value, accessibilityDescription: description)!
                }
                #endif
            }
            """
        return [decl]
    }

    private static func accessControl(from arg: LabeledExprListSyntax.Element?) throws -> String {
        guard let accessLevel = arg?.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text else {
            if let arg {
                throw DiagnosticsError(node: Syntax(arg), message: .cannotParseAccessLevel)
            } else {
                return ""
            }
        }
        return accessLevel
    }

    private static func sfSymbolNames(from arg: LabeledExprListSyntax.Element?) throws -> [String] {
        if let arrayExprSyntax = arg?.expression.as(ArrayExprSyntax.self) {
            try sfSymbolNames(from: arrayExprSyntax)
        } else if let closureExprSyntax = arg?.expression.as(ClosureExprSyntax.self) {
            try sfSymbolNames(from: closureExprSyntax)
        } else {
            []
        }
    }

    private static func sfSymbolNames(from arrayExprSyntax: ArrayExprSyntax) throws -> [String] {
        let elements = arrayExprSyntax.elements
        guard !elements.isEmpty else { throw DiagnosticsError(node: Syntax(elements), message: .emptyNames) }
        var visitedNames: Set<String> = []
        return try elements.map {
            guard let name = $0.contentText() else {
                throw DiagnosticsError(node: Syntax($0), message: .cannotParseNames)
            }
            guard name.isValidSFSymbolName else {
                throw DiagnosticsError(node: Syntax($0), message: .invalidSFSymbolName(name))
            }
            guard visitedNames.insert(name).inserted else {
                throw DiagnosticsError(node: Syntax($0), message: .redundantName(name))
            }
            return name
        }
    }

    private static func sfSymbolNames(from closureExprSyntax: ClosureExprSyntax?) throws -> [String] {
        guard let closureExprSyntax else { return [] }
        var visitedNames: Set<String> = []
        return try closureExprSyntax.statements.map {
            guard let name = $0.contentText() else {
                throw DiagnosticsError(node: Syntax($0), message: .cannotParseNames)
            }
            guard name.isValidSFSymbolName else {
                throw DiagnosticsError(node: Syntax($0), message: .invalidSFSymbolName(name))
            }
            guard visitedNames.insert(name).inserted else {
                throw DiagnosticsError(node: Syntax($0), message: .redundantName(name))
            }
            return name
        }
    }

    private static func caseExpression(name: String) -> String {
        let camel = name.camelCased()
        return if name == camel {
            keywords.contains(name) ? "case `\(name)`" : "case \(name)"
        } else {
            "case \(camel) = \"\(name)\""
        }
    }

    private static let internalAccess: String = "internal"
    private static let publicAccess: String = "public"
    private static let keywords: Set<String> = [
        "Any", "Protocol", "Self", "Type", "any", "as", "associatedtype", "associativity", "await", "break", "case",
        "catch", "catch", "class", "continue", "convenience", "default", "defer", "deinit", "didSet", "do", "dynamic",
        "else", "enum", "extension", "fallthrough", "false", "fileprivate", "final", "for", "func", "get", "guard",
        "if", "import", "in", "indirect", "infix", "init", "inout", "internal", "is", "lazy", "left", "let", "mutating",
        "nil", "none", "nonmutating", "open", "operator", "optional", "override", "postfix", "precedence",
        "precedencegroup", "prefix", "private", "protocol", "public", "repeat", "required", "rethrows", "rethrows",
        "return", "right", "self", "set", "some", "static", "struct", "subscript", "super", "switch", "throw", "throw",
        "throws", "true", "try", "typealias", "unowned", "var", "weak", "where", "while", "willSet",
    ]
}

extension ArrayElementSyntax {
    fileprivate func contentText() -> String? {
        expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
}

extension CodeBlockItemSyntax {
    fileprivate func contentText() -> String? {
        item.as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content
            .text
    }
}

extension String {
    fileprivate var isValidSFSymbolName: Bool {
        #if canImport(UIKit)
        if UIImage(systemName: self) != nil { return true }
        #else
        if NSImage(systemSymbolName: self, accessibilityDescription: nil) != nil { return true }
        #endif
        return false
    }

    fileprivate func camelCased() -> String {
        reduce(into: "") {
            if $0.last == "." {
                $0.removeLast()
                $0.append($1.uppercased())
            } else {
                $0.append($1)
            }
        }
    }
}

enum SFSymbolMacroDiagnostic: DiagnosticMessage {
    case emptyNames
    case cannotParseNames
    case invalidSFSymbolName(String)
    case redundantName(String)
    case cannotParseAccessLevel

    var severity: DiagnosticSeverity { .error }

    var message: String {
        switch self {
        case .emptyNames:
            "Empty SF Symbol names"
        case .cannotParseNames:
            "Cannot parse SF Symbol names"
        case .invalidSFSymbolName(let name):
            "`\(name)` is not a valid SF Symbol name"
        case .redundantName(let name):
            "Redundant SF Symbol name: '\(name)'"
        case .cannotParseAccessLevel:
            "Cannot parse access level"
        }
    }

    var diagnosticID: MessageID { .init(domain: "SFSymbolMacro", id: self.message) }
}

extension DiagnosticsError {
    fileprivate init(node: Syntax, message: SFSymbolMacroDiagnostic) {
        self.init(diagnostics: [
            .init(node: node, message: message)
        ])
    }
}

@main
struct SFSymbolsGeneratorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SFSymbolMacro.self
    ]
}
