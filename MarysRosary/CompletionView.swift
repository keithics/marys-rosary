import SwiftUI

private let blessings: [String] = [
    "May the grace of the Rosary draw you ever closer to the Heart of Jesus through Mary.",
    "The Rosary is the weapon for these times. Pray it daily and place yourself under her mantle.\n— Our Lady of Fatima",
    "Never will anyone who says the Rosary every day become a formal heretic or be led astray by the devil.\n— St. Louis de Montfort",
    "To Jesus through Mary — may this Rosary be your offering today.",
    "She is the Queen of the Rosary. May she carry your intentions to her Son."
]

struct CompletionView: View {
    let mysteryType: MysteryType
    let onPrayAgain: () -> Void

    private let navy   = Color(red: 0.16, green: 0.20, blue: 0.34)
    private let gold   = Color(red: 0.78, green: 0.62, blue: 0.28)

    @State private var appeared = false
    private let blessing = blessings[Int.random(in: 0..<blessings.count)]

    var body: some View {
        ZStack {
            SkyBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Medal
                Image("MadonnaMedal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110)
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 32)

                Text("Rosary Complete")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundStyle(navy)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 6)

                Text(mysteryType.displayName)
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(gold)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 28)

                HStack(spacing: 12) {
                    line; sparkle; line
                }
                .frame(width: 180)
                .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 28)

                Text(blessing)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(navy.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 44)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                Button(action: onPrayAgain) {
                    HStack(spacing: 10) {
                        Image(systemName: "hands.sparkles.fill")
                            .font(.system(size: 15))
                        Text("Pray Again")
                            .font(.system(size: 17, weight: .medium, design: .serif))
                    }
                    .foregroundStyle(navy)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(.white.opacity(0.90)))
                    .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
                }
                .opacity(appeared ? 1 : 0)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                appeared = true
            }
        }
    }

    private var line: some View {
        Rectangle()
            .fill(navy.opacity(0.30))
            .frame(height: 1)
    }

    private var sparkle: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 11))
            .foregroundStyle(gold)
    }
}
