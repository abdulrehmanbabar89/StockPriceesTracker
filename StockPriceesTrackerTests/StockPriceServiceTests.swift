import Testing
import Foundation
@testable import StockPriceesTracker

@Suite("StockPriceService")
struct StockPriceServiceTests {

    @Test("Start price feed connects WebSocket")
    func startConnects() async {
        let mockWS = MockWebSocketService()
        let service = StockPriceService(webSocketService: mockWS, symbols: ["AAPL"], updateInterval: 10)

        await service.startPriceFeed()
        #expect(await mockWS.connectCallCount == 1)
    }

    @Test("Stop price feed disconnects WebSocket")
    func stopDisconnects() async {
        let mockWS = MockWebSocketService()
        let service = StockPriceService(webSocketService: mockWS, symbols: ["AAPL"], updateInterval: 10)

        await service.startPriceFeed()
        await service.stopPriceFeed()
        #expect(await mockWS.disconnectCallCount == 1)
    }
}
