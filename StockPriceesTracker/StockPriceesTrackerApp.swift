import SwiftUI

@main
struct StockPriceesTrackerApp: App {
    private let container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            // the coordinator owns the navigation stack and shows the list as the first screen
            CoordinatorView(coordinator: container.appCoordinator)
        }
    }
}
