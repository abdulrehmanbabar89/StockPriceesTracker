import Foundation
import Synchronization

// Broadcaster to update the statuses of different things properly specially connection status of websocket and price updates in stock and web socket service.
nonisolated final class AsyncBroadcaster<Element: Sendable>: Sendable {
    private struct State {
        var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]
        var latest: Element?
    }

    private let state = Mutex(State())
    private let replaysLatest: Bool

    init(replaysLatest: Bool = false) {
        self.replaysLatest = replaysLatest
    }

    func stream() -> AsyncStream<Element> {
        let (stream, continuation) = AsyncStream<Element>.makeStream(bufferingPolicy: .bufferingNewest(64))
        let id = UUID()
        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { _ = $0.continuations.removeValue(forKey: id) }
        }
        state.withLock { state in
            state.continuations[id] = continuation
            if replaysLatest, let latest = state.latest {
                continuation.yield(latest)
            }
        }
        return stream
    }

    func yield(_ element: Element) {
        let continuations = state.withLock { state in
            state.latest = element
            return Array(state.continuations.values)
        }
        for continuation in continuations {
            continuation.yield(element)
        }
    }

    deinit {
        for continuation in state.withLock({ Array($0.continuations.values) }) {
            continuation.finish()
        }
    }
}
