import SwiftUI

struct SkyBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.87, blue: 0.95),
                    Color(red: 0.93, green: 0.95, blue: 0.98),
                    Color(red: 0.99, green: 0.99, blue: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            cloud(width: 320, height: 120).offset(x: -60, y: -220).opacity(0.9)
            cloud(width: 260, height: 100).offset(x: 110, y: -40).opacity(0.7)
            cloud(width: 300, height: 110).offset(x: -90, y: 230).opacity(0.8)
            cloud(width: 240, height: 90).offset(x: 120, y: 320).opacity(0.7)
        }
    }

    private func cloud(width: CGFloat, height: CGFloat) -> some View {
        Ellipse()
            .fill(.white)
            .frame(width: width, height: height)
            .blur(radius: 40)
    }
}
