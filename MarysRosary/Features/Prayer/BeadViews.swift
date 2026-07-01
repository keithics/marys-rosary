import SwiftUI

/// A gold "Hail Mary" bead — shown when active or already recited.
struct GoldBead: View {
    let diameter: CGFloat
    var mystery: MysteryType = .joyful

    var body: some View {
        Image("GoldenBead-\(mystery.rawValue)")
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .shadow(color: .black.opacity(0.22), radius: diameter * 0.06, y: diameter * 0.04)
    }
}

/// A glass "Hail Mary" bead — shown when not yet recited.
struct GlassBead: View {
    let diameter: CGFloat

    var body: some View {
        Image("GlassBead")
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .shadow(color: .black.opacity(0.18), radius: diameter * 0.06, y: diameter * 0.04)
    }
}

/// A small gold chain ring/link that sits between the main beads, rotated to
/// follow the direction of the string.
struct ChainLink: View {
    let diameter: CGFloat
    var rotation: Angle = .zero

    var body: some View {
        Image("Chain")
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .rotationEffect(rotation)
            .shadow(color: .black.opacity(0.18), radius: diameter * 0.12, y: diameter * 0.05)
    }
}

/// A pearl-white "Our Father" bead.
struct PearlBead: View {
    let diameter: CGFloat
    var mystery: MysteryType = .joyful

    var body: some View {
        Image("NormalBead-\(mystery.rawValue)")
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .shadow(color: .black.opacity(0.20), radius: diameter * 0.06, y: diameter * 0.04)
    }
}

/// A silver Trinity knot bead used for Glory Be prayers.
struct TrinityBead: View {
    let diameter: CGFloat

    var body: some View {
        Image("TrinityBead")
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .shadow(color: .black.opacity(0.22), radius: diameter * 0.06, y: diameter * 0.04)
    }
}

/// The centerpiece medal showing the Madonna and Child image.
/// The PNG already has a transparent background and built-in decorative border + connector rings.
struct MedalBead: View {
    let diameter: CGFloat

    var body: some View {
        Image("MadonnaMedal")
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .shadow(color: .black.opacity(0.35), radius: diameter * 0.08, y: diameter * 0.04)
    }
}

/// The crucifix that hangs at the bottom of the rosary tail.
/// Image is 719×1190 portrait with transparent background.
struct CrucifixView: View {
    let height: CGFloat

    var body: some View {
        Image("Crucifix")
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .shadow(color: .black.opacity(0.30), radius: height * 0.04, y: height * 0.03)
    }
}

struct MagicEffect: View {
    let diameter: CGFloat

    @State private var glowing  = false
    @State private var orbiting = false

    private let dustCount = 12
    private let gold      = Color(red: 1.0, green: 0.84, blue: 0.42)
    private let warmWhite = Color(red: 1.0, green: 0.97, blue: 0.85)

    var body: some View {
        ZStack {
            // Pulsing golden halo
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear,             location: 0.00),
                            .init(color: .clear,             location: 0.50),
                            .init(color: gold.opacity(0.55), location: 0.66),
                            .init(color: .clear,             location: 1.00)
                        ]),
                        center: .center, startRadius: 0, endRadius: diameter
                    )
                )
                .frame(width: diameter * 2.0, height: diameter * 2.0)
                .scaleEffect(glowing ? 1.10 : 1.00)
                .opacity(glowing ? 0.58 : 0.30)

            // Orbiting dust ring — rotates as a unit, no per-frame maths
            ZStack {
                ForEach(0..<dustCount, id: \.self) { i in
                    let angle = (Double(i) / Double(dustCount)) * 2 * .pi
                    let s     = diameter * 0.07
                    Circle()
                        .fill(gold.opacity(0.9))
                        .frame(width: s, height: s)
                        .offset(x: cos(angle) * diameter * 0.72,
                                y: sin(angle) * diameter * 0.72)
                }
            }
            .rotationEffect(.degrees(orbiting ? 360 : 0))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                glowing = true
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                orbiting = true
            }
        }
        .allowsHitTesting(false)
    }
}
