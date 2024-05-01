import SFSymbolsGenerator
import SwiftUI

#SFSymbol {
    "star"
    "case"
    "star.square.on.square"
}

extension Image {
    init(sfSymbol: SFSymbol) {
        self.init(systemName: sfSymbol.name)
    }
}

struct ContentView: View {
    #SFSymbol(
        accessLevel: .public,
        names: [
            "drop.fill",
            "flame.fill",
        ])

    var body: some View {
        VStack {
            SFSymbol.dropFill.image()
            SFSymbol.flameFill.image()
            Divider()
            Image(sfSymbol: .star)
            Image(sfSymbol: .case)
            Image(sfSymbol: .starSquareOnSquare)
        }
        .padding(100)
    }
}

#Preview {
    ContentView()
}
