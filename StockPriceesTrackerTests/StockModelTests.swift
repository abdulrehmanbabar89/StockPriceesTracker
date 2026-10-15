import Testing
import Foundation
@testable import StockPriceesTracker

@Suite("Stock Model")
struct StockModelTests {

    @Test("Price change direction is up when change is positive")
    func priceChangeDirectionUp() {
        var stock = StockCatalog.all[0]
        stock.priceChange = 2.50
        #expect(stock.changeDirection == .up)
    }

    @Test("Stock catalog contains 25 symbols")
    func catalogContains25Symbols() {
        #expect(StockCatalog.all.count == 25)
    }
}
