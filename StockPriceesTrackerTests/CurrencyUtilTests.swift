import Testing
import Foundation
@testable import StockPriceesTracker

@Suite("CurrencyUtil")
struct CurrencyUtilTests {

    @Test("Currency code comes from the locale")
    func currencyCode() {
        let util = CurrencyUtil(locale: Locale(identifier: "en_US"))
        #expect(util.currencyCode == "USD")
    }

    @Test("Price is formatted in the locale's currency")
    func formatPrice() {
        let util = CurrencyUtil(locale: Locale(identifier: "en_US"))
        #expect(util.formatPrice(1234.5) == "$1,234.50")
    }
}
