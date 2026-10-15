import SwiftUI

struct StockRowView: View {
    let stock: Stock

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedPrice)
                    .font(.headline)
                    .monospacedDigit()

                PriceChangeIndicator(
                    change: stock.priceChange,
                    changePercentage: stock.priceChangePercentage
                )
            }
        }
        .padding(.vertical, 4)
    }

    private var formattedPrice: String {
        CurrencyUtil.shared.formatPrice(stock.currentPrice)
    }
}

struct PriceChangeIndicator: View {
    let change: Double
    let changePercentage: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption2)
            Text(formattedChange)
                .font(.subheadline)
                .monospacedDigit()
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
    }

    private var iconName: String {
        if change > 0 { return "arrow.up.right" }
        if change < 0 { return "arrow.down.right" }
        return "minus"
    }

    private var color: Color {
        if change > 0 { return .green }
        if change < 0 { return .red }
        return .secondary
    }

    private var formattedChange: String {
        let currency = CurrencyUtil.shared
        return "\(currency.formatPriceChange(change)) (\(currency.formatPercentChange(changePercentage)))"
    }
}
