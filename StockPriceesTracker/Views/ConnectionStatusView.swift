import SwiftUI

struct ConnectionStatusView: View {
    let status: ConnectionStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .lineLimit(1)
        }
        .fixedSize()
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .animation(.easeInOut(duration: 0.3), value: status)
    }

    private var color: Color {
        switch status {
        case .connecting: .orange
        case .connected: .green
        case .disconnected: .red
        }
    }

    private var label: String {
        switch status {
        case .connecting: "Connecting…"
        case .connected: "Connected"
        case .disconnected: "Disconnected"
        }
    }
}
