import SwiftUI

struct MysteryIcon: View {
    let kind: MysteryType.IconKind

    var body: some View {
        switch kind {
        case .svg(let name):
            Image(name)
                .resizable()
                .scaledToFit()
        case .fa6(let char):
            Text(char)
                .font(.custom("FontAwesome6Free-Solid", size: 18))
        case .sf(let symbol):
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .medium))
        }
    }
}
