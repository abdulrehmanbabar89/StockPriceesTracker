import Foundation

/// Formats prices in the currency of a locale (the user's locale by default).
nonisolated final class CurrencyUtil: Sendable {
    static let shared = CurrencyUtil()

    private static let fallbackCurrencyCode = "USD"

    let locale: Locale

    /// - Parameter locale: Defaults to `autoupdatingCurrent`, so a region change in Settings
    ///   is picked up without restarting the app.
    init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }

    /// ISO 4217 code of the locale's currency, e.g. "USD", "EUR", "JPY".
    var currencyCode: String {
        locale.currency?.identifier ?? Self.fallbackCurrencyCode
    }

    /// "$1,234.50", "1.234,50 €", "¥1,234.50"…
    func formatPrice(_ value: Double) -> String {
        value.formatted(currencyStyle)
    }

    /// Always signed: "+$1.25", "-$0.40", "+$0.00".
    func formatPriceChange(_ value: Double) -> String {
        value.formatted(currencyStyle.sign(strategy: .always(showZero: true)))
    }

    /// Takes a value already in percent units and always signs it: 2.5 → "+2.50%".
    func formatPercentChange(_ value: Double) -> String {
        value.formatted(
            .percent
                .scale(1)
                .locale(locale)
                .precision(.fractionLength(2))
                .sign(strategy: .always(includingZero: true))
        )
    }

    /// Always two decimals so small moves don't round away in currencies such as JPY that
    /// have no minor unit.
    private var currencyStyle: FloatingPointFormatStyle<Double>.Currency {
        .currency(code: currencyCode)
            .locale(locale)
            .precision(.fractionLength(2))
    }
}
