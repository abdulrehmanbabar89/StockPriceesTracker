import Foundation

// assumed properties of Stock
nonisolated struct Stock: Identifiable, Equatable, Sendable {
    let id: String
    let symbol: String
    let name: String
    let description: String
    var currentPrice: Double
    var previousPrice: Double
    var priceChange: Double
    var priceChangePercentage: Double

    var changeDirection: PriceChangeDirection {
        if priceChange > 0 {
            return .up
        }
        else if priceChange < 0 {
            return .down
        }
        return .unchanged
    }
}

// enum for showing direction for price change
enum PriceChangeDirection: Sendable {
    case up
    case down
    case unchanged
}

struct PriceUpdate: Codable, Sendable {
    let symbol: String
    let price: Double
    let timestamp: Date
}

// Sort options required
enum SortOption: String, CaseIterable, Sendable {
    case byPrice = "Price"
    case byPriceChange = "Price Change"
}

enum ConnectionStatus: Equatable, Sendable {
    case connecting
    case connected
    case disconnected
}

// the Stocks json is placed in resources and data is taken from json
enum StockCatalog {
    static let all: [Stock] = load()

    static func load(from bundle: Bundle = .main, fileName: String = "stocks") -> [Stock] {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            fatalError("\(fileName).json is missing from the app bundle")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([StockSeed].self, from: data).map(\.stock)
        } catch {
            fatalError("Failed to decode \(fileName).json: \(error)")
        }
    }
}

// DTO for stock json map, it will map into Stock
nonisolated private struct StockSeed: Decodable {
    let symbol: String
    let name: String
    let description: String
    let price: Double

    var stock: Stock {
        Stock(
            id: symbol,
            symbol: symbol,
            name: name,
            description: description,
            currentPrice: price,
            previousPrice: price,
            priceChange: 0,
            priceChangePercentage: 0
        )
    }
}
