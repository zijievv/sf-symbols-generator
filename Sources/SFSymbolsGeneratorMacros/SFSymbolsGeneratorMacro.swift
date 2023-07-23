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
        guard
            let elements = node
                .argumentList.first?.expression.as(ArrayExprSyntax.self)?
                .elements.as(ArrayElementListSyntax.self)
        else {
            return []
        }
        guard !elements.isEmpty else { throw DiagnosticsError(node: Syntax(elements), message: .emptyNames) }
        var visitedNames: Set<String> = []
        let names = try elements.map {
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
        let decl: DeclSyntax = """
enum SFSymbol: String {
    \(raw: names.map(caseExpression(name:)).joined(separator: "\n    "))

    var name: String { self.rawValue }

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
"""
        return [decl]
    }

    private static func caseExpression(name: String) -> String {
        let camel = name.camelCased()
        return if name == camel {
            keywords.contains(name) ? "case `\(name)`" : "case \(name)"
        } else {
            "case \(camel) = \"\(name)\""
        }
    }

    private static let keywords = Set([
        "Any", "Protocol", "Self", "Type", "any", "as", "associatedtype", "associativity", "await", "break", "case",
        "catch", "catch", "class", "continue", "convenience", "default", "defer", "deinit", "didSet", "do", "dynamic",
        "else", "enum", "extension", "fallthrough", "false", "fileprivate", "final", "for", "func", "get", "guard",
        "if", "import", "in", "indirect", "infix", "init", "inout", "internal", "is", "lazy", "left", "let", "mutating",
        "nil", "none", "nonmutating", "open", "operator", "optional", "override", "postfix", "precedence",
        "precedencegroup", "prefix", "private", "protocol", "public", "repeat", "required", "rethrows", "rethrows",
        "return", "right", "self", "set", "some", "static", "struct", "subscript", "super", "switch", "throw", "throw",
        "throws", "true", "try", "typealias", "unowned", "var", "weak", "where", "while", "willSet",
    ])
}

extension ArrayElementSyntax {
    fileprivate func contentText() -> String? {
        expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .as(StringLiteralSegmentsSyntax.self)?
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
            "Redundant SF Symbol name: `\(name)`"
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
