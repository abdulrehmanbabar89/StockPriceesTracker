import SwiftUI

@main
struct StockPriceesTrackerApp: App {
    private let container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            // giving first view as listview
            StockListView(viewModel: container.stockListViewModel)
        }
    }
}
