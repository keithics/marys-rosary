import SwiftUI

struct BorderProgressFromTopRight: Shape {
    var progress: Double
    let cornerRadius: CGFloat

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = min(cornerRadius, rect.width / 2, rect.height / 2)
        let arc = (.pi / 2) * r
        let top = rect.width - 2 * r
        let side = rect.height - 2 * r
        let total = 4 * arc + 2 * top + 2 * side
        var rem = CGFloat(progress) * total

        p.move(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        guard rem > 0 else { return p }

        func addArcSeg(cx: CGFloat, cy: CGFloat, start: Double, end: Double) {
            let seg = min(rem, arc)
            let deg = Double(seg / r) * (180 / .pi)
            p.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                     startAngle: .degrees(start), endAngle: .degrees(start + deg), clockwise: false)
            rem -= seg
        }

        addArcSeg(cx: rect.maxX - r, cy: rect.minY + r, start: 270, end: 360)
        guard rem > 0 else { return p }

        let s1 = min(rem, side)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + r + s1))
        rem -= s1; guard rem > 0 else { return p }

        addArcSeg(cx: rect.maxX - r, cy: rect.maxY - r, start: 0, end: 90)
        guard rem > 0 else { return p }

        let s2 = min(rem, top)
        p.addLine(to: CGPoint(x: rect.maxX - r - s2, y: rect.maxY))
        rem -= s2; guard rem > 0 else { return p }

        addArcSeg(cx: rect.minX + r, cy: rect.maxY - r, start: 90, end: 180)
        guard rem > 0 else { return p }

        let s3 = min(rem, side)
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - r - s3))
        rem -= s3; guard rem > 0 else { return p }

        addArcSeg(cx: rect.minX + r, cy: rect.minY + r, start: 180, end: 270)
        guard rem > 0 else { return p }

        let s4 = min(rem, top)
        p.addLine(to: CGPoint(x: rect.minX + r + s4, y: rect.minY))

        return p
    }
}
