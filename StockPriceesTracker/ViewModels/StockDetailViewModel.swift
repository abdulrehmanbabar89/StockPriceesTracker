import Foundation
import Observation

@Observable
final class StockDetailViewModel {
    let symbol: String
    private let listViewModel: StockListViewModel

    var stock: Stock? {
        listViewModel.stock(for: symbol)
    }

    init(symbol: String, listViewModel: StockListViewModel) {
        self.symbol = symbol
        self.listViewModel = listViewModel
    }
}
