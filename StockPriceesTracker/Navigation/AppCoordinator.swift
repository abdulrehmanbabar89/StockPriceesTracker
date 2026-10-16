import SwiftUI

@Observable
final class AppCoordinator {
    var path = NavigationPath()

    private let stockListViewModel: StockListViewModel

    init(stockListViewModel: StockListViewModel) {
        self.stockListViewModel = stockListViewModel
    }

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func rootView() -> some View {
        StockListView(viewModel: stockListViewModel)
    }

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .stockDetail(let symbol):
            StockDetailView(
                viewModel: StockDetailViewModel(symbol: symbol, listViewModel: stockListViewModel)
            )
        }
    }
}
