import SwiftUI

struct StockListView: View {
    @Bindable var viewModel: StockListViewModel

    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            ForEach(viewModel.stocks) { stock in
                Button {
                    coordinator.push(.stockDetail(symbol: stock.symbol))
                } label: {
                    StockRowView(stock: stock)
                }
                .foregroundStyle(.primary)
            }
        }
        .navigationTitle("Stocks")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ConnectionStatusView(status: viewModel.connectionStatus)
            }
            ToolbarItem(placement: .topBarTrailing) {
                sortMenu
            }
            ToolbarItem(placement: .bottomBar) {
                feedButton
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }

    private var feedButton: some View {
        Button {
            viewModel.toggleFeed()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: viewModel.isFeedActive ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title2)
                Text(viewModel.isFeedActive ? "Stop Feed" : "Start Feed")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(viewModel.isFeedActive ? .red : .green)
        }
    }
}
