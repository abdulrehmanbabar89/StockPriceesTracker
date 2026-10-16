import Foundation

// This is my dependency injector to avoid always initializing services

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()

    private init() {}

    private lazy var webSocketService: WebSocketServiceProtocol = {
        WebSocketService(url: AppConstants.WebSocket.url)
    }()

    private lazy var stockPriceService: StockPriceServiceProtocol = {
        let symbols = StockCatalog.all.map(\.symbol)
        return StockPriceService(
            webSocketService: webSocketService,
            symbols: symbols,
            updateInterval: 1.0
        )
    }()

    lazy var stockListViewModel: StockListViewModel = {
        StockListViewModel(priceService: stockPriceService)
    }()
}
