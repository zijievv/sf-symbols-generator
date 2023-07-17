import SFSymbolsGenerator
import SwiftUI

#SFSymbol(names: [
    "star",
    "star.fill",
    "star.square.on.square",
])

struct ContentView: View {
    var body: some View {
        VStack {
            SFSymbol.star.image()
            SFSymbol.starFill.image()
            SFSymbol.starSquareOnSquare.image()
        }
        .padding(100)
    }
}

#Preview {
    ContentView()
}
