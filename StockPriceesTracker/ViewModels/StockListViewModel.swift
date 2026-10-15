import Foundation
import Observation

@Observable
final class StockListViewModel {
    private(set) var stocks: [Stock] = StockCatalog.all
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    var sortOption: SortOption = .byPrice {
        didSet { applySorting() }
    }

    var isConnected: Bool {
        connectionStatus == .connected
    }

    /// The feed is running or on its way up, so the button should offer "Stop".
    var isFeedActive: Bool {
        connectionStatus != .disconnected
    }

    private let priceService: StockPriceServiceProtocol
    private var priceUpdateTask: Task<Void, Never>?
    private var statusTask: Task<Void, Never>?
    /// The latest start/stop request; each one waits for the previous so they reach the service in order.
    private var transitionTask: Task<Void, Never>?

    init(priceService: StockPriceServiceProtocol) {
        self.priceService = priceService
        observeService()
    }

    isolated deinit {
        priceUpdateTask?.cancel()
        statusTask?.cancel()
    }

    func startFeed() {
        enqueueTransition { await $0.startPriceFeed() }
    }

    func stopFeed() {
        enqueueTransition { await $0.stopPriceFeed() }
    }

    func toggleFeed() {
        if isFeedActive {
            stopFeed()
        } else {
            startFeed()
        }
    }

    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }

    /// Subscriptions live as long as the view model; start/stop only drive the service.
    private func observeService() {
        priceUpdateTask = Task { [weak self, priceService] in
            for await update in priceService.priceUpdateStream {
                self?.applyUpdate(update)
            }
        }

        statusTask = Task { [weak self, priceService] in
            for await status in priceService.connectionStatusStream {
                self?.connectionStatus = status
            }
        }
    }

    private func enqueueTransition(_ operation: @escaping @Sendable (StockPriceServiceProtocol) async -> Void) {
        let previous = transitionTask
        transitionTask = Task { [priceService] in
            await previous?.value
            await operation(priceService)
        }
    }

    private func applyUpdate(_ update: PriceUpdate) {
        guard let index = stocks.firstIndex(where: { $0.symbol == update.symbol }) else { return }
        var stock = stocks[index]
        stock.previousPrice = stock.currentPrice
        stock.currentPrice = update.price
        stock.priceChange = update.price - stock.previousPrice
        if stock.previousPrice != 0 {
            stock.priceChangePercentage = (stock.priceChange / stock.previousPrice) * 100
        }
        stocks[index] = stock
        applySorting()
    }

    private func applySorting() {
        switch sortOption {
        case .byPrice:
            stocks.sort { $0.currentPrice > $1.currentPrice }
        case .byPriceChange:
            stocks.sort { abs($0.priceChange) > abs($1.priceChange) }
        }
    }
}
