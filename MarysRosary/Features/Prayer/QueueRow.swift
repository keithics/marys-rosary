import SwiftUI

struct QueueRow: View {
    let row: (index: Int, bead: Bead)
    let currentBead: Int
    let navy: Color
    let gold: Color
    let onSelect: (Int) -> Void

    private var state: RowState {
        if row.index == currentBead { return .active }
        if row.index < currentBead  { return .done }
        return .upcoming
    }

    var body: some View {
        Button { onSelect(row.index) } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 36, height: 36)
                    Image(systemName: iconName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(iconForeground)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(row.bead.primaryPrayer?.title ?? "—")
                        .font(.system(size: 15, weight: state == .active ? .semibold : .regular, design: .serif))
                        .foregroundStyle(state == .done ? navy.opacity(0.40) : navy)

                    if row.bead.prayers.count > 1 {
                        Text(row.bead.prayers.dropFirst().compactMap(\.title).joined(separator: " · "))
                            .font(.system(size: 11, weight: .regular, design: .serif))
                            .foregroundStyle(navy.opacity(0.35))
                            .lineLimit(1)
                    }
                }

                Spacer()

                if state == .active {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(gold)
                } else if state == .done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(navy.opacity(0.25))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(state == .active ? gold.opacity(0.08) : .clear)
        }
        .buttonStyle(.plain)
    }

    private enum RowState { case done, active, upcoming }

    private var iconName: String {
        switch row.bead.kind {
        case .crucifix: return "cross.fill"
        case .medal:    return "star.fill"
        case .gold:     return "circle.fill"
        case .crystal:  return "circle"
        }
    }

    private var iconBackground: Color {
        switch state {
        case .active:   return gold.opacity(0.18)
        case .done:     return navy.opacity(0.06)
        case .upcoming: return navy.opacity(0.06)
        }
    }

    private var iconForeground: Color {
        switch row.bead.kind {
        case .gold:     return state == .done ? navy.opacity(0.30) : gold
        case .crucifix: return state == .done ? navy.opacity(0.30) : navy.opacity(0.70)
        case .medal:    return state == .done ? navy.opacity(0.30) : gold
        case .crystal:  return state == .done ? navy.opacity(0.30) : navy.opacity(0.55)
        }
    }
}
