import Foundation

// this is constants file for all constants. In case of more apis, i would make separae base api class and put base URL there. as its just a socket, so I used constants
nonisolated enum AppConstants {
    enum WebSocket {
        static let url = URL(string: "wss://ws.postman-echo.com/raw")!
    }
}
