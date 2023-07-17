import SFSymbolsGenerator
import SwiftUI

#SFSymbol(names: [
    "star",
    "case",
    "star.fill",
    "star.square.on.square",
])

struct ContentView: View {
    var body: some View {
        VStack {
            SFSymbol.star.image()
            SFSymbol.starFill.image()
            SFSymbol.starSquareOnSquare.image()
            SFSymbol.case.image()
        }
        .padding(100)
    }
}

#Preview {
    ContentView()
}
