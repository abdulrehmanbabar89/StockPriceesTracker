import Foundation

// this is my Util class to show proper currency code according to current locale like UAE, US or any country. CUrrently I took USD by default
nonisolated final class CurrencyUtil: Sendable {
    static let shared = CurrencyUtil()

    private static let fallbackCurrencyCode = "USD"

    let locale: Locale

    init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }

    var currencyCode: String {
        locale.currency?.identifier ?? Self.fallbackCurrencyCode
    }

    func formatPrice(_ value: Double) -> String {
        value.formatted(currencyStyle)
    }

    func formatPriceChange(_ value: Double) -> String {
        value.formatted(currencyStyle.sign(strategy: .always(showZero: true)))
    }

    func formatPercentChange(_ value: Double) -> String {
        value.formatted(
            .percent
                .scale(1)
                .locale(locale)
                .precision(.fractionLength(2))
                .sign(strategy: .always(includingZero: true))
        )
    }

    // show always 2 decimal places
    private var currencyStyle: FloatingPointFormatStyle<Double>.Currency {
        .currency(code: currencyCode)
            .locale(locale)
            .precision(.fractionLength(2))
    }
}
