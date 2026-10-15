import SwiftUI

@main
struct StockPriceesTrackerApp: App {
    private let container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            StockListView(viewModel: container.stockListViewModel)
        }
    }
}
