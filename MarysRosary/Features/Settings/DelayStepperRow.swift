import SwiftUI

struct DelayStepperRow: View {
    let label: String
    let isResponse: Bool
    let delay: Int
    let canDecrement: Bool
    let theme: MysteryTheme
    let isLast: Bool
    var hideBottomDivider: Bool = false
    let onChange: (Int) -> Void

    private var snippet: String {
        let words = label.split(separator: " ").prefix(7).joined(separator: " ")
        return words + (label.split(separator: " ").count > 7 ? "…" : "")
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(snippet)
                .font(.system(size: 13, design: .serif))
                .foregroundStyle(theme.textPrimary.opacity(0.65))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Button { onChange(delay - 1) } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .foregroundStyle(canDecrement ? theme.accent : theme.textSubtle.opacity(0.3))
                }
                .buttonStyle(.plain)
                .disabled(!canDecrement)

                Text("\(delay)s")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                    .frame(minWidth: 38)
                    .multilineTextAlignment(.center)

                Button { onChange(delay + 1) } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .foregroundStyle(delay < 120 ? theme.accent : theme.textSubtle.opacity(0.3))
                }
                .buttonStyle(.plain)
                .disabled(delay >= 120)
            }
            .background(Capsule().fill(theme.accent.opacity(0.08)))
        }
        .padding(.horizontal, 14)
        .padding(.top, isResponse ? 18 : 10)
        .padding(.bottom, 10)
        .overlay(alignment: .top) {
            if isResponse {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(theme.accent.opacity(0.25))
                        .frame(height: 0.5)
                    Text("Response")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.5)
                        .foregroundStyle(theme.accent)
                        .fixedSize()
                    Rectangle()
                        .fill(theme.accent.opacity(0.25))
                        .frame(height: 0.5)
                }
                .padding(.horizontal, 14)
            }
        }
        .overlay(alignment: .bottom) {
            if !isLast && !hideBottomDivider {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 0.5)
                    .padding(.leading, 14)
            }
        }
    }
}
