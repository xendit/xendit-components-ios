//
//  SessionTelemetry.swift
//  XenditComponents
//

import Foundation
import UIKit

// MARK: - Input event

struct SessionTelemetryEvent {
    let stage: String
    let success: Bool
    var paymentChannel: String?
    var paymentRequestId: String?
    var paymentTokenId: String?
    var metadata: [String: Any]?
}

// MARK: - Scope

/// Tracks which event is the current "parent" so subsequent events inherit parent_event_id
/// and payment identifiers. Passed back from appendAndPushScope so callers can pop it later.
final class SessionTelemetryScope {
    let id: String?
    let fromEvent: String
    private(set) weak var parentScope: SessionTelemetryScope?

    var parentEventId: String?
    var paymentChannel: String?
    var paymentRequestId: String?
    var paymentTokenId: String?

    fileprivate init(id: String?, fromEvent: String, parent: SessionTelemetryScope?) {
        self.id = id
        self.fromEvent = fromEvent
        self.parentScope = parent
    }
}

// MARK: - Queue entry

struct SessionTelemetryQueueEntry {
    let eventId: String
    let timestampMicros: String
    let stage: String
    let success: Bool
    var parentEventId: String?
    var paymentChannel: String?
    var paymentRequestId: String?
    var paymentTokenId: String?
    var metadata: [String: Any]?

    func toDictionary() -> [String: Any] {
        var d: [String: Any] = [
            "event_id": eventId,
            "timestamp_micros": timestampMicros,
            "stage": stage,
            "success": success
        ]
        if let parentEventId    { d["parent_event_id"]     = parentEventId }
        if let paymentChannel   { d["payment_channel"]     = paymentChannel }
        if let paymentRequestId { d["payment_request_id"]  = paymentRequestId }
        if let paymentTokenId   { d["payment_token_id"]    = paymentTokenId }
        if let metadata         { d["metadata"]            = metadata }
        return d
    }
}

// MARK: - SessionTelemetry

@MainActor
final class SessionTelemetry {

    private static let flushInterval: TimeInterval = 2
    private static let maxQueueSize = 25

    private(set) var queue: [SessionTelemetryQueueEntry] = []

    private let rootScope: SessionTelemetryScope
    private(set) var scope: SessionTelemetryScope

    private var flushWorkItem: DispatchWorkItem?
    private var backgroundObserver: NSObjectProtocol?
    private var terminateObserver: NSObjectProtocol?

    private weak var sdk: XenditComponents?

    /// Called after each flush attempt. Intended for test observation only.
    var onFlushed: (() -> Void)?

    init(sdk: XenditComponents) {
        self.sdk = sdk
        let root = SessionTelemetryScope(id: nil, fromEvent: "ROOT", parent: nil)
        rootScope = root
        scope = root
    }

    // ponytail: testing init — sdk nil keeps flush as a no-op so events stay in queue for inspection
    init() {
        self.sdk = nil
        let root = SessionTelemetryScope(id: nil, fromEvent: "ROOT", parent: nil)
        rootScope = root
        scope = root
    }

    // MARK: - Public API

    /// Appends an event to the queue. Returns the generated event_id.
    @discardableResult
    func append(_ event: SessionTelemetryEvent) -> String {
        let eventId = UUID().uuidString
        queue.append(SessionTelemetryQueueEntry(
            eventId: eventId,
            timestampMicros: "\(Int64(Date().timeIntervalSince1970 * 1_000_000))",
            stage: event.stage,
            success: event.success,
            parentEventId: scope.parentEventId,
            paymentChannel: event.paymentChannel ?? scope.paymentChannel,
            paymentRequestId: event.paymentRequestId ?? scope.paymentRequestId,
            paymentTokenId: event.paymentTokenId ?? scope.paymentTokenId,
            metadata: sanitize(event.metadata)
        ))
        setup()
        return eventId
    }

    /// Appends an event and makes it the parent of all subsequent events.
    /// Returns the new scope — pass it to popScope when the flow stage ends.
    @discardableResult
    func appendAndPushScope(_ event: SessionTelemetryEvent) -> SessionTelemetryScope {
        let id = append(event)
        let newScope = SessionTelemetryScope(id: id, fromEvent: event.stage, parent: scope)
        newScope.parentEventId = id
        newScope.paymentChannel = event.paymentChannel ?? scope.paymentChannel
        newScope.paymentRequestId = event.paymentRequestId ?? scope.paymentRequestId
        newScope.paymentTokenId = event.paymentTokenId ?? scope.paymentTokenId
        scope = newScope
        return newScope
    }

    /// Restores scope to the parent of the given scope.
    /// Safe to call with a scope that is no longer active (no-op).
    func popScope(_ scopeToPop: SessionTelemetryScope) {
        guard let parent = scopeToPop.parentScope else { return }

        // Verify the scope is still in the stack before popping.
        var check: SessionTelemetryScope = scope
        while true {
            if check === scopeToPop { break }
            guard let next = check.parentScope else { return }
            check = next
        }

        scope = parent
    }

    /// Sends all queued events. Called automatically by the timer, background, and terminate observers.
    func flush() {
        defer { onFlushed?() }

        guard let sdk, let parsedKey = sdk.parsedKey else {
            // sdk deallocated or key not parsed — keep events, teardown so we stop firing.
            teardown()
            return
        }

        guard let sessionId = sdk.stateStore.session?.id else {
            // Session not loaded yet — keep events and observers so they flush once session arrives.
            return
        }

        // Always teardown after this point: we either send or the queue is empty.
        teardown()

        guard !queue.isEmpty else { return }

        let events = queue.map { $0.toDictionary() }
        queue = []

        let body: [String: Any] = [
            "payment_session_id": sessionId,
            "session_auth_id": parsedKey.sessionAuthKey,
            "events": events
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: body),
              let url = URL(string: parsedKey.telemetryURL.absoluteString + "/v1/sessions/performance") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // ponytail: text/plain matches sendBeacon's content-type so the backend handles both web and iOS identically
        request.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        URLSession.shared.uploadTask(with: request, from: data).resume()
    }

    // MARK: - Private

    private func setup() {
        if flushWorkItem == nil {
            let item = DispatchWorkItem { [weak self] in Task { @MainActor [weak self] in self?.flush() } }
            flushWorkItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.flushInterval, execute: item)
        }

        if backgroundObserver == nil {
            backgroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in Task { @MainActor [weak self] in self?.flush() } }
        }

        if terminateObserver == nil {
            terminateObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willTerminateNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in Task { @MainActor [weak self] in self?.flush() } }
        }

        if queue.count >= Self.maxQueueSize {
            flush()
        }
    }

    private func teardown() {
        flushWorkItem?.cancel()
        flushWorkItem = nil

        if let obs = backgroundObserver {
            NotificationCenter.default.removeObserver(obs)
            backgroundObserver = nil
        }
        if let obs = terminateObserver {
            NotificationCenter.default.removeObserver(obs)
            terminateObserver = nil
        }
    }

    private func sanitize(_ metadata: [String: Any]?) -> [String: Any]? {
        guard let metadata else { return nil }
        let filtered = metadata.filter {
            if let str = $0.value as? String { return !str.isEmpty }
            return true
        }
        return filtered.isEmpty ? nil : filtered
    }
}
