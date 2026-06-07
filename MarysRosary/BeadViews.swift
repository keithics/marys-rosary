import SwiftUI

/// A gold "Hail Mary" bead — shown when active or already recited.
struct GoldBead: View {
    let diameter: CGFloat

    var body: some View {
        Image("GoldenBead")
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

/// A pearl-white "Our Father" bead — same art as GoldenBead, desaturated to ivory pearl.
struct PearlBead: View {
    let diameter: CGFloat

    var body: some View {
        Image("GoldenBead")
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .saturation(0.0)
            .colorMultiply(Color(red: 1.0, green: 0.98, blue: 0.94))
            .brightness(0.06)
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

/// A magical effect for the bead currently being prayed: a soft pulsing golden
/// halo with little sparkles of "fairy dust" orbiting around it.
/// `diameter` is the visible diameter of the bead it surrounds.
struct MagicEffect: View {
    let diameter: CGFloat

    private let dustCount = 12
    private let gold = Color(red: 1.0, green: 0.84, blue: 0.42)
    private let warmWhite = Color(red: 1.0, green: 0.97, blue: 0.85)

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let pulse = 1.0 + 0.10 * sin(t * 2.3)
            let glow = 0.30 + 0.28 * (0.5 + 0.5 * sin(t * 2.3))

            ZStack {
                // Pulsing golden halo — a ring around the bead, clear in the center.
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .clear, location: 0.50),
                                .init(color: gold.opacity(0.55), location: 0.66),
                                .init(color: .clear, location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: diameter
                        )
                    )
                    .frame(width: diameter * 2.0, height: diameter * 2.0)
                    .scaleEffect(pulse)
                    .opacity(glow)

                // Orbiting fairy dust.
                ForEach(0..<dustCount, id: \.self) { i in
                    let seed = Double(i)
                    let angle = (seed / Double(dustCount)) * 2 * .pi + t * 0.9
                    let r = diameter * (0.68 + 0.12 * sin(t * 1.6 + seed * 1.3))
                    let twinkle = 0.20 + 0.80 * pow(0.5 + 0.5 * sin(t * 3.0 + seed * 2.1), 2)
                    let s = diameter * (0.05 + 0.035 * (0.5 + 0.5 * sin(t * 2.2 + seed)))

                    Circle()
                        .fill(warmWhite)
                        .frame(width: s, height: s)
                        .shadow(color: gold, radius: s * 0.9)
                        .shadow(color: gold.opacity(0.7), radius: s * 1.8)
                        .opacity(twinkle)
                        .offset(x: cos(angle) * r, y: sin(angle) * r)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
