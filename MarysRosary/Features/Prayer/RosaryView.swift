import SwiftUI

/// Computed geometry for laying the rosary out in its intrinsic (large) space.
private struct Layout {
    let center: CGPoint
    let radius: CGFloat
    let medal: CGPoint
    let loopPoints: [CGPoint]   // one per loop bead, in prayer order
    let tailPoints: [CGPoint]   // [0]=nearest medal, [last]=outermost/crucifix
    let tailCount: Int
    let loopCount: Int

    /// Maps a sequence index to its screen position.
    /// Handles the double traversal of the tail (opening inward, closing outward).
    ///
    /// Layout:
    ///   [0 ..< tailCount]            → opening tail, tailPoints[tailCount-1-i] (outer→inner)
    ///   [tailCount]                  → medal (first visit)
    ///   [tailCount+1 ..< tailCount+1+loopCount] → loopPoints
    ///   [tailCount+1+loopCount]      → medal (second visit)
    ///   beyond                       → closing tail, tailPoints[0..] (inner→outer)
    func point(forSequenceIndex i: Int) -> CGPoint {
        if i < tailCount {
            return tailPoints[tailCount - 1 - i]
        }
        if i == tailCount { return medal }
        let li = i - tailCount - 1
        if li < loopCount { return loopPoints[li] }
        if li == loopCount { return medal }
        return tailPoints[li - loopCount - 1]
    }
}

/// A scale + translation that maps intrinsic layout coordinates onto the screen.
private struct Camera {
    var scale: CGFloat
    var offset: CGSize
}

struct RosaryView: View {
    let rosary: Rosary
    @Binding var current: Int
    @Binding var zoomLevel: Double
    @Binding var learningMode: Bool
    @AppStorage("showMagicEffect") private var showMagicEffect = false

    var body: some View {
        GeometryReader { geo in
            let layout = makeLayout(in: geo.size)
            let goldD    = layout.radius * 0.058
            let crystalD = layout.radius * 0.070
            let medalD   = layout.radius * 0.420
            let crucifixH = layout.radius * 0.220
            let chainD   = layout.radius * 0.030

            let points = rosary.sequence.indices.map { layout.point(forSequenceIndex: $0) }

            // Medal artwork ring connection points
            let medalLeft   = CGPoint(x: layout.medal.x - medalD * 0.27, y: layout.medal.y - medalD * 0.45)
            let medalRight  = CGPoint(x: layout.medal.x + medalD * 0.27, y: layout.medal.y - medalD * 0.45)
            let medalBottom = CGPoint(x: layout.medal.x,                  y: layout.medal.y + medalD * 0.46)

            let links = chainLinks(layout: layout, points: points,
                                   medalLeft: medalLeft, medalRight: medalRight, medalBottom: medalBottom)
            let cam = camera(in: geo.size, points: points)

            ZStack(alignment: .topLeading) {
                string(layout: layout, medalLeft: medalLeft, medalRight: medalRight, medalBottom: medalBottom)

                ForEach(Array(links.enumerated()), id: \.offset) { _, link in
                    ChainLink(diameter: chainD, rotation: link.angle).position(link.point)
                }

                // Opening tail = indices 0..<tailCount, closing tail = indices > tailCount+1+loopCount.
                // Both sets share the same physical tailPoints positions. Use z-index to show
                // the relevant phase's bead on top: opening during opening/loop, closing during closing.
                let closingStart = layout.tailCount + 1 + layout.loopCount
                let inClosingPhase = current >= closingStart

                ForEach(Array(rosary.sequence.enumerated()), id: \.offset) { index, bead in
                    let p = points[index]
                    let isMedal    = bead.kind == .medal
                    let isActive   = index == current

                    let isOpeningTail = index < layout.tailCount
                    let isClosingTail = index > closingStart
                    let isRelevantTail = (isOpeningTail && !inClosingPhase) || (isClosingTail && inClosingPhase)

                    let isTailBead = isOpeningTail || isClosingTail
                    let isHidden   = isTailBead && !isRelevantTail && !isActive
                    let isCrucifix = bead.kind == .crucifix
                    let visibleD: CGFloat = isMedal ? medalD
                        : isCrucifix ? crucifixH * 0.38
                        : bead.kind == .gold ? goldD : crystalD

                    ZStack {
                        if isMedal {
                            MedalBead(diameter: medalD)
                        } else {
                            switch bead.kind {
                            case .crucifix: CrucifixView(height: crucifixH)
                            case .gold:
                                if index <= current {
                                    GoldBead(diameter: goldD, mystery: rosary.mysteryType)
                                } else {
                                    GlassBead(diameter: goldD)
                                }
                            default:
                                if bead.primaryPrayer?.id == "glory_be" {
                                    TrinityBead(diameter: crystalD)
                                } else {
                                    PearlBead(diameter: crystalD, mystery: rosary.mysteryType)
                                }
                            }
                        }

                        if isActive && showMagicEffect {
                            MagicEffect(diameter: visibleD)
                                .offset(y: isCrucifix ? -crucifixH * 0.12 : 0)
                        }
                    }
                    .position(p)
                    .opacity(isHidden ? 0 : 1)
                    .zIndex(isActive ? 2 : (isRelevantTail ? 1 : 0))
                    .onTapGesture {
                        guard learningMode else { return }
                        withAnimation(.easeInOut(duration: 0.6)) {
                            current = index
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            .scaleEffect(cam.scale, anchor: .topLeading)
            .offset(cam.offset)
            .animation(.spring(response: 0.55, dampingFraction: 0.78), value: current)
            .animation(.easeInOut(duration: 0.3), value: zoomLevel)
        }
    }

    // MARK: - Camera (zoom)

    private func camera(in size: CGSize, points: [CGPoint]) -> Camera {
        let s = CGFloat(zoomLevel)
        let target = points[min(current, points.count - 1)]
        let anchor = CGPoint(x: size.width / 2, y: size.height * 0.22)
        return Camera(scale: s,
                      offset: CGSize(width: anchor.x - target.x * s,
                                     height: anchor.y - target.y * s))
    }

    // MARK: - String

    /// Draws the connecting string bead-to-bead only (chain links handle medal ring connections).
    private func string(layout: Layout,
                        medalLeft: CGPoint, medalRight: CGPoint, medalBottom: CGPoint) -> some View {
        Path { path in
            // Loop: bead-to-bead
            if let first = layout.loopPoints.first {
                path.move(to: first)
                for p in layout.loopPoints.dropFirst() { path.addLine(to: p) }
            }
            // Tail: bead-to-bead (outermost → nearest medal)
            if layout.tailPoints.count > 1 {
                path.move(to: layout.tailPoints[layout.tailPoints.count - 1])
                for p in layout.tailPoints.dropLast().reversed() { path.addLine(to: p) }
            }
        }
        .stroke(
            Color(red: 0.82, green: 0.66, blue: 0.32).opacity(0.75),
            style: StrokeStyle(lineWidth: max(1, layout.radius * 0.004), lineCap: .round, lineJoin: .round)
        )
    }

    // MARK: - Chain links

    /// Two chain rings on every link between consecutive beads.
    /// Segments adjacent to the medal terminate at the physical ring positions.
    private func chainLinks(layout: Layout, points: [CGPoint],
                            medalLeft: CGPoint, medalRight: CGPoint,
                            medalBottom: CGPoint) -> [(point: CGPoint, angle: Angle)] {
        let tailCount = layout.tailCount
        let loopCount = layout.loopCount

        // Build unique physical segments (tail + loop only, no duplicates from double traversal).
        var segments: [(CGPoint, CGPoint)] = []

        // Tail segments: tailPoints[last] (outermost) → ... → tailPoints[0] (nearest) → medalBottom
        let tail = layout.tailPoints
        for i in stride(from: tail.count - 1, through: 1, by: -1) {
            segments.append((tail[i], tail[i - 1]))
        }
        if let nearest = tail.first {
            segments.append((nearest, medalBottom))
        }

        // Loop segments: medalLeft → loopPoints[0], ..., loopPoints[last] → medalRight
        let loop = layout.loopPoints
        if let first = loop.first {
            segments.append((medalLeft, first))
        }
        for i in 0..<(loop.count - 1) {
            segments.append((loop[i], loop[i + 1]))
        }
        if let last = loop.last {
            segments.append((last, medalRight))
        }

        // Place two chain links per segment at 1/3 and 2/3 positions.
        var result: [(point: CGPoint, angle: Angle)] = []
        for (a, b) in segments {
            let angle = Angle.radians(atan2(b.y - a.y, b.x - a.x) + .pi / 2)
            for t in [1.0 / 3.0, 2.0 / 3.0] {
                let p = CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
                result.append((p, angle))
            }
        }
        // Suppress unused-variable warnings for tailCount/loopCount (used in point mapping only).
        _ = tailCount; _ = loopCount
        return result
    }

    // MARK: - Layout

    private func makeLayout(in size: CGSize) -> Layout {
        let ry       = size.height * 0.80
        let rxTop    = ry * 0.82
        let rxBottom = ry * 0.52
        let medalD   = ry * 0.420
        let ringY    = size.height * 0.56
        let center   = CGPoint(x: size.width / 2, y: ringY - ry)
        let medal    = CGPoint(x: center.x, y: ringY + medalD * 0.45)

        func pos(_ a: Double) -> CGPoint {
            let yN = sin(a)
            let rx = rxBottom + (rxTop - rxBottom) * (1 - yN) / 2
            return CGPoint(x: center.x + rx * cos(a), y: center.y + ry * sin(a))
        }

        let gapHalf = 28.0 * .pi / 180
        let start = .pi / 2 + gapHalf
        let end   = .pi / 2 + 2 * .pi - gapHalf

        // Arc-length parameterize the loop curve.
        let steps = 600
        var pts: [CGPoint] = [pos(start)]
        var cum: [Double]  = [0]
        for i in 1...steps {
            let a = start + (end - start) * Double(i) / Double(steps)
            let p = pos(a)
            cum.append(cum[i - 1] + hypot(p.x - pts[i - 1].x, p.y - pts[i - 1].y))
            pts.append(p)
        }
        let total = cum.last ?? 0

        let count = rosary.loopCount
        let loopPoints: [CGPoint] = (0..<count).map { j in
            let target = total * Double(j) / Double(max(1, count - 1))
            var k = 0
            while k < cum.count - 1 && cum[k + 1] < target { k += 1 }
            guard k < pts.count - 1 else { return pts[pts.count - 1] }
            let seg = cum[k + 1] - cum[k]
            let f   = seg > 0 ? (target - cum[k]) / seg : 0
            return CGPoint(x: pts[k].x + (pts[k + 1].x - pts[k].x) * f,
                           y: pts[k].y + (pts[k + 1].y - pts[k].y) * f)
        }

        // Tail: [0]=nearest medal, [tailCount-1]=outermost/crucifix
        // Start below the medal's visual bottom (medalD/2 ≈ ry*0.21) with a small gap.
        let n = rosary.tailCount
        let spacing       = ry * 0.10
        let crucifixExtra = ry * 0.12
        let tailBaseY     = medal.y + medalD * 0.60   // safely below medal bottom
        let tailPoints: [CGPoint] = (0..<n).map { i in
            let isOuter = (i == n - 1)
            let extra: CGFloat = isOuter ? crucifixExtra : 0
            return CGPoint(x: center.x, y: tailBaseY + spacing * Double(i) + extra)
        }

        return Layout(center: center, radius: ry, medal: medal,
                      loopPoints: loopPoints, tailPoints: tailPoints,
                      tailCount: n, loopCount: count)
    }
}
