import SwiftUI

struct QueueSheet: View {
    let rosary: Rosary
    let currentBead: Int
    let onSelect: (Int) -> Void
    let onStop: () -> Void

    private let navy = Color(red: 0.16, green: 0.20, blue: 0.34)
    private let gold = Color(red: 0.78, green: 0.62, blue: 0.28)

    private var rows: [(index: Int, bead: Bead)] {
        rosary.sequence.enumerated()
            .filter { !$0.element.isVisualOnly }
            .map { (index: $0.offset, bead: $0.element) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prayer Sequence")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(navy)
                Spacer()
                Button(role: .destructive, action: onStop) {
                    Label("Stop Prayer", systemImage: "stop.circle.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.red.opacity(0.75))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(rows, id: \.index) { row in
                            QueueRow(
                                row: row,
                                currentBead: currentBead,
                                navy: navy,
                                gold: gold,
                                onSelect: onSelect
                            )
                            .id(row.index)

                            if row.index != rows.last?.index {
                                Divider().padding(.leading, 56)
                            }
                        }
                    }
                }
                .onAppear {
                    let activeRow = rows.last(where: { $0.index <= currentBead })?.index
                        ?? rows.first?.index
                    if let target = activeRow {
                        proxy.scrollTo(target, anchor: .center)
                    }
                }
            }
        }
    }
}
