import Testing
import SwiftUI
@testable import StockPriceesTracker

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {

    @Test("Push adds a screen to the path")
    func push() {
        let coordinator = AppCoordinator(stockListViewModel: StockListViewModel(priceService: MockStockPriceService()))
        coordinator.push(.stockDetail(symbol: "AAPL"))
        #expect(coordinator.path.count == 1)
    }

    @Test("Pop to root clears the path")
    func popToRoot() {
        let coordinator = AppCoordinator(stockListViewModel: StockListViewModel(priceService: MockStockPriceService()))
        coordinator.push(.stockDetail(symbol: "AAPL"))
        coordinator.push(.stockDetail(symbol: "MSFT"))
        coordinator.popToRoot()
        #expect(coordinator.path.isEmpty)
    }
}
