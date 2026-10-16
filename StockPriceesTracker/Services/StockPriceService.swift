import Foundation

nonisolated protocol StockPriceServiceProtocol: Sendable {
    func startPriceFeed() async
    func stopPriceFeed() async
    /// Each access returns a new subscription.
    var priceUpdateStream: AsyncStream<PriceUpdate> { get }
    /// Each access returns a new subscription that starts with the current status.
    var connectionStatusStream: AsyncStream<ConnectionStatus> { get }
}

actor StockPriceService: StockPriceServiceProtocol {
    private let webSocketService: WebSocketServiceProtocol
    private let symbols: [String]
    private let updateInterval: TimeInterval
    private var feedTask: Task<Void, Never>?
    private var receiveTask: Task<Void, Never>?
    /// Bumped on every start/stop so a `startPriceFeed` resumed after a newer call backs off.
    private var generation = 0
    private let priceUpdates = AsyncBroadcaster<PriceUpdate>()
    private var livePrices: [String: Double]

    nonisolated var priceUpdateStream: AsyncStream<PriceUpdate> { priceUpdates.stream() }
    nonisolated var connectionStatusStream: AsyncStream<ConnectionStatus> {
        webSocketService.statusStream
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        webSocketService: WebSocketServiceProtocol,
        symbols: [String],
        updateInterval: TimeInterval = 1.0
    ) {
        self.webSocketService = webSocketService
        self.symbols = symbols
        self.updateInterval = updateInterval

        var prices: [String: Double] = [:]
        for stock in StockCatalog.all {
            prices[stock.symbol] = stock.currentPrice
        }
        self.livePrices = prices

        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func startPriceFeed() async {
        // Restarting after a dropped connection must not leave the old loops running.
        cancelTasks()
        generation += 1
        let current = generation
        // Subscribe before connecting so the first echo can't be missed.
        startReceiving()
        do {
            try await webSocketService.connect()
        } catch {
            if generation == current { cancelTasks() }
            return
        }
        guard generation == current else { return }
        startSending()
    }

    func stopPriceFeed() async {
        cancelTasks()
        generation += 1
        await webSocketService.disconnect()
    }

    private func cancelTasks() {
        feedTask?.cancel()
        receiveTask?.cancel()
        feedTask = nil
        receiveTask = nil
    }

    // Here we are sending stream to socket after each second
    private func startSending() {
        let interval = updateInterval
        feedTask = Task { [weak self] in
            while !Task.isCancelled {
                // Stop the loop once the socket is gone instead of failing every tick.
                guard let self, await self.sendNextPrice() else { break }
                try? await Task.sleep(for: .milliseconds(Int(interval * 1000)))
            }
        }
    }

    // here is am sending next price update for a random stock and some randomw value from -0.03 to 0.03
    private func sendNextPrice() async -> Bool {
        let symbol = symbols.randomElement() ?? "AAPL"
        let currentPrice = livePrices[symbol] ?? 100.0

        let changePercent = Double.random(in: -0.03...0.03)
        let newPrice = currentPrice * (1.0 + changePercent)
        let roundedPrice = (newPrice * 100).rounded() / 100
        livePrices[symbol] = roundedPrice

        let update = PriceUpdate(
            symbol: symbol,
            price: roundedPrice,
            timestamp: Date()
        )

        guard let data = try? encoder.encode(update),
              let jsonString = String(data: data, encoding: .utf8) else { return true }
        do {
            print("[WebSocket SEND] \(symbol): $\(String(format: "%.2f", roundedPrice))")
            try await webSocketService.send(jsonString)
            return true
        } catch {
            print("[WebSocket SEND] failed: \(error.localizedDescription)")
            return false
        }
    }

    // recieving socket message
    private func startReceiving() {
        let stream = webSocketService.messageStream
        receiveTask = Task { [weak self] in
            for await data in stream {
                await self?.handleMessage(data)
            }
        }
    }

    private func handleMessage(_ data: Data) {
        guard let update = try? decoder.decode(PriceUpdate.self, from: data) else { return }
        print("[WebSocket RECV] \(update.symbol): $\(String(format: "%.2f", update.price)) (echoed)")
        priceUpdates.yield(update)
    }
}
