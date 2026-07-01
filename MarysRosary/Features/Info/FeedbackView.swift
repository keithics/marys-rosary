import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var today: MysteryType = .forToday()

    var body: some View {
        ZStack {
            today.theme.cloud.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer()
                mailContent
                Spacer()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Feedback")
                .font(.kaushan(38))
                .foregroundStyle(today.theme.textPrimary)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(today.theme.textSubtle.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
        .padding(.bottom, 6)
    }

    // MARK: - Mail CTA

    private var mailContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 52))
                .foregroundStyle(today.theme.accent)

            VStack(spacing: 8) {
                Text("We'd love to hear from you.")
                    .font(.kaushan(26))
                    .foregroundStyle(today.theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Tap below to send us your thoughts,\nsuggestions, or prayer requests.")
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(today.theme.textSubtle)
                    .multilineTextAlignment(.center)
            }

            Button {
                openMail()
            } label: {
                Label("Send Feedback", systemImage: "envelope")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(today.theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Action

    private func openMail() {
        let subject = "Mary's Rosary Feedback"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "mailto:keithics@me.com?subject=\(subject)") else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    FeedbackView()
}
