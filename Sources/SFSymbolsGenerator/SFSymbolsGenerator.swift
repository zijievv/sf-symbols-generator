@freestanding(declaration, names: named(SFSymbol))
public macro SFSymbol(names: [String]) = #externalMacro(module: "SFSymbolsGeneratorMacros", type: "SFSymbolMacro")
