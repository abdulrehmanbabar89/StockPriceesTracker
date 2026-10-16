import Foundation
@testable import StockPriceesTracker

actor MockWebSocketService: WebSocketServiceProtocol {
    nonisolated var messageStream: AsyncStream<Data> { AsyncStream { $0.finish() } }
    nonisolated var statusStream: AsyncStream<ConnectionStatus> { AsyncStream { $0.finish() } }

    
    // adding for tests
    private(set) var connectCallCount = 0
    private(set) var disconnectCallCount = 0

    func connect() async throws {
        connectCallCount += 1
    }

    func disconnect() async {
        disconnectCallCount += 1
    }

    func send(_ message: String) async throws {}
}
