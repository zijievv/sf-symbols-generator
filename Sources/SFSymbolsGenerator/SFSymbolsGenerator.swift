@freestanding(declaration, names: named(SFSymbol))
public macro SFSymbol(
    accessLevel: AccessLevel = .internal,
    names: [String]
) = #externalMacro(module: "SFSymbolsGeneratorMacros", type: "SFSymbolMacro")

@freestanding(declaration, names: named(SFSymbol))
public macro SFSymbol(
    accessLevel: AccessLevel = .internal,
    @SFSymbolNamesBuilder namesBuilder: () -> [String]
) = #externalMacro(module: "SFSymbolsGeneratorMacros", type: "SFSymbolMacro")

@resultBuilder
public enum SFSymbolNamesBuilder {
    public static func buildBlock(_ components: String...) -> [String] {
        components
    }
}

public enum AccessLevel {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
}
