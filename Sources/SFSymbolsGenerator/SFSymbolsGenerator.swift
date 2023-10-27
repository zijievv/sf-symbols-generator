public enum AccessLevel {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
}

@freestanding(declaration, names: named(SFSymbol))
public macro SFSymbol(
    accessLevel: AccessLevel = .internal,
    names: [String]
) = #externalMacro(module: "SFSymbolsGeneratorMacros", type: "SFSymbolMacro")
