# StockPriceesTracker

A SwiftUI app that shows live prices for 25 stocks using a WebSocket.

The prices are simulated. Every second the app picks a stock, changes its price a little and sends it to `wss://ws.postman-echo.com/raw`. The server echoes the message back and that echoed message is what updates the list. So even though the data is fake, it still goes through a real socket.

## Features

- List of 25 stocks with price change and percentage
- Sort by price or by price change
- Detail screen with the stock description
- Connection status (Connecting, Connected, Disconnected)
- Start / Stop feed button
- Prices formatted with the user's locale and currency

## Requirements

- Xcode 27
- iOS 26.5
- No third-party libraries

## How to run

Open `StockPriceesTracker.xcodeproj`, pick an iPhone simulator and run. Tap **Start Feed** to start getting prices.

Run the tests with ⌘U.

## Project structure

- `Models` - `Stock`, `PriceUpdate`, `ConnectionStatus`, `SortOption` and `StockCatalog`, which loads the stocks from `Resources/stocks.json`
- `Services` - `WebSocketService` (the socket), `StockPriceService` (generates, sends and decodes prices), `AsyncBroadcaster` and `DependencyContainer`
- `ViewModels` - `StockListViewModel` and `StockDetailViewModel`
- `Views` - the SwiftUI screens
- `Utilities` - `AppConstants` (socket URL) and `CurrencyUtil` (price formatting)

The app uses MVVM. Services are behind protocols and are created in `DependencyContainer`, so they can be replaced with mocks in tests.

## Some notes on the implementation

I used `URLSessionWebSocketTask` instead of a socket library to keep the project free of dependencies.

After opening the socket I send a ping and only show "Connected" once the pong comes back. This way the status doesn't say connected before the handshake has actually finished.

`WebSocketService` and `StockPriceService` are actors, so their state is safe across threads. The project's default isolation is `MainActor`, and models and helpers that are used from the services are marked `nonisolated`.

`AsyncBroadcaster` exists because a normal `AsyncStream` can only be used once. When the task reading it gets cancelled (which happens on Stop), the stream is finished for good and Start would stop working. The broadcaster creates a new stream for every subscriber, so stopping and starting again works fine.

Start and stop requests are handled in the order they are tapped, so tapping the button quickly doesn't leave the app in a weird state.

`stocks.json` is decoded into a small private struct (`StockSeed`) and then mapped to `Stock`. The JSON only has the fixed data and the opening price, while `Stock` also has values that change at runtime.

## Tests

The tests use Swift Testing with mock services, so they don't need the network. They cover the stock model, `CurrencyUtil`, the list view model and the price service.

## Known limitations

- Prices are fake and come from a public echo server
- The currency symbol follows the user's locale but the price is not converted
- No automatic reconnect if the connection drops
- The project is still in Swift 5 mode

## Ideas for later

- Reconnect automatically and pause the feed when the app goes to the background
- Show an error message when the connection fails
- Move to Swift 6
- Add a price chart on the detail screen
