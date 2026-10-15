import Foundation

nonisolated enum WebSocketError: Error {
    case notConnected
}

nonisolated protocol WebSocketServiceProtocol: Sendable {
    /// Opens the socket and returns once the handshake has completed. Throws if it cannot connect.
    func connect() async throws
    func disconnect() async
    func send(_ message: String) async throws
    /// Each access returns a new subscription.
    var messageStream: AsyncStream<Data> { get }
    /// Each access returns a new subscription that starts with the current status.
    var statusStream: AsyncStream<ConnectionStatus> { get }
}

actor WebSocketService: WebSocketServiceProtocol {
    private let url: URL
    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private let messages = AsyncBroadcaster<Data>()
    private let status = AsyncBroadcaster<ConnectionStatus>(replaysLatest: true)

    nonisolated var messageStream: AsyncStream<Data> { messages.stream() }
    nonisolated var statusStream: AsyncStream<ConnectionStatus> { status.stream() }

    init(url: URL) {
        self.url = url
        self.session = URLSession(configuration: .default)
        status.yield(.disconnected)
    }

    func connect() async throws {
        // Drop any previous socket so its receive loop can't report on the new connection.
        tearDown()

        let task = session.webSocketTask(with: url)
        webSocketTask = task
        status.yield(.connecting)
        print("Connecting to \(url.absoluteString)...")
        task.resume()

        do {
            // A ping only gets its pong after the handshake, so this confirms the socket is open.
            try await Self.ping(task)
        } catch {
            if webSocketTask === task {
                tearDown()
                status.yield(.disconnected)
            }
            print("WebSocket connection failed: \(error.localizedDescription)")
            throw error
        }

        // disconnect() or another connect() may have run while we were awaiting the pong.
        guard webSocketTask === task else { throw CancellationError() }

        receiveTask = Task { [weak self] in
            await self?.receiveMessages(from: task)
        }
        status.yield(.connected)
        print("WebSocket connected")
    }

    func disconnect() async {
        guard webSocketTask != nil else { return }
        tearDown()
        print("WebSocket disconnected")
        status.yield(.disconnected)
    }

    func send(_ message: String) async throws {
        guard let webSocketTask else { throw WebSocketError.notConnected }
        try await webSocketTask.send(.string(message))
    }

    private func tearDown() {
        receiveTask?.cancel()
        receiveTask = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }

    private func receiveMessages(from task: URLSessionWebSocketTask) async {
        while !Task.isCancelled {
            do {
                switch try await task.receive() {
                case .data(let data):
                    messages.yield(data)
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        messages.yield(data)
                    }
                @unknown default:
                    break
                }
            } catch {
                // Errors from a socket we closed on purpose are expected; only report a drop
                // of the socket that is still current.
                guard webSocketTask === task else { return }
                print("WebSocket receive error: \(error.localizedDescription)")
                tearDown()
                status.yield(.disconnected)
                return
            }
        }
    }

    private static func ping(_ task: URLSessionWebSocketTask) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            task.sendPing { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
