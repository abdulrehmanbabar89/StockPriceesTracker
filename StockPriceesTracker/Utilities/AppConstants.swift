import Foundation

nonisolated enum AppConstants {
    enum WebSocket {
        static let url = URL(string: "wss://ws.postman-echo.com/raw")!
    }
}
