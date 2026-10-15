import SwiftUI

struct StockDetailView: View {
    let viewModel: StockDetailViewModel

    var body: some View {
        Group {
            if let stock = viewModel.stock {
                stockContent(stock)
            } else {
                ContentUnavailableView(
                    "Symbol Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Could not find data for \(viewModel.symbol)")
                )
            }
        }
        .navigationTitle(viewModel.symbol)
        .navigationBarTitleDisplayMode(.large)
    }

    private func stockContent(_ stock: Stock) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                priceCard(stock)
                descriptionCard(stock)
            }
            .padding()
        }
    }

    private func priceCard(_ stock: Stock) -> some View {
        VStack(spacing: 16) {
            Text(stock.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text(CurrencyUtil.shared.formatPrice(stock.currentPrice))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: stock.currentPrice)

            PriceChangeIndicator(
                change: stock.priceChange,
                changePercentage: stock.priceChangePercentage
            )
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func descriptionCard(_ stock: Stock) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("About \(stock.symbol)", systemImage: "info.circle")
                .font(.headline)

            Text(stock.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
