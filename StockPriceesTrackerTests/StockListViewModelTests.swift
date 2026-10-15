import Testing
import Foundation
@testable import StockPriceesTracker

actor MockStockPriceService: StockPriceServiceProtocol {
    nonisolated var priceUpdateStream: AsyncStream<PriceUpdate> { AsyncStream { $0.finish() } }
    nonisolated var connectionStatusStream: AsyncStream<ConnectionStatus> { AsyncStream { $0.finish() } }

    func startPriceFeed() async {}
    func stopPriceFeed() async {}
}

@Suite("StockListViewModel")
@MainActor
struct StockListViewModelTests {

    @Test("Initial connection status is disconnected")
    func initialConnectionStatus() {
        let viewModel = StockListViewModel(priceService: MockStockPriceService())
        #expect(viewModel.connectionStatus == .disconnected)
    }

    @Test("Stock lookup by symbol works")
    func stockLookup() {
        let viewModel = StockListViewModel(priceService: MockStockPriceService())
        #expect(viewModel.stock(for: "AAPL")?.name == "Apple Inc.")
    }
}
