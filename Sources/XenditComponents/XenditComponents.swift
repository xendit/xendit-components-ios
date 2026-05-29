//
//  XenditComponents.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import Combine
import Foundation
import SwiftUI
import UIKit

/// The main entry point for the Xendit Components iOS SDK.
///
/// ## App startup
/// Call `XenditComponents.initialize(appearance:)` once to register fonts and configure
/// global visual styling before presenting any payment sheet.
///
/// ## UIKit
/// ```swift
/// XenditComponents.initialize(appearance: XenditAppearance())
///
/// XenditComponents.present(from: viewController, componentsSdkKey: "your-key") { result in
///     switch result {
///     case .success(let id, _): print("Paid: \(id)")
///     case .dismissed, .canceled: break
///     case .failed(let error):   print(error)
///     }
/// }
/// ```
///
/// ## SwiftUI
/// Create an instance, embed `XenditSheetView`, and call `initialize()` in `.task`:
/// ```swift
/// let sdk = XenditComponents(componentsSdkKey: "your-key")
/// sdk.initialize().sink(...).store(in: &cancellables)
/// ```
@MainActor
public final class XenditComponents: ObservableObject {

    // MARK: - Global configuration

    /// Visual styling applied to all SDK-rendered UI.
    /// Mutate via `initialize(appearance:)` before presenting the payment sheet.
    /// `nonisolated(unsafe)` allows font helpers in InterFont/InterUIFont to read this from
    /// nonisolated contexts. Safe because appearance is always written before any rendering occurs.
    public nonisolated(unsafe) static private(set) var appearance = XenditAppearance()

    // MARK: - Static API

    /// Configures global appearance and registers SDK resources.
    ///
    /// Call once at app startup. Safe to call again to update appearance at runtime.
    ///
    /// - Parameter appearance: Visual styling applied to all SDK UI elements.
    public static func initialize(appearance: XenditAppearance) {
        self.appearance = appearance
        InterFont.register()
        APIClient.setup(
            config: APIClient.Config(appVersion: sdkVersion, bundleHostId: Bundle.main.bundleIdentifier),
            settings: APIClient.shared.settings
        )
    }

    /// Presents the Xendit payment sheet modally over `viewController`.
    ///
    /// The SDK instance is retained internally for the lifetime of the sheet and released
    /// automatically once the sheet is dismissed.
    ///
    /// - Parameters:
    ///   - viewController: The view controller from which to present the sheet.
    ///   - componentsSdkKey: Session-scoped key obtained from your backend.
    ///   - onResult: Invoked on the main thread with the final payment outcome.
    public static func present(
        from viewController: UIViewController,
        componentsSdkKey: String,
        onResult: @escaping (XenditPaymentResult) -> Void
    ) {
        let sdk = XenditComponents(componentsSdkKey: componentsSdkKey)
        activeSDK = sdk

        let sheetView = XenditSheetView(sdk: sdk) { result in
            viewController.dismiss(animated: true) {
                sdk.eventListeners.removeAll()
                activeSDK = nil
                onResult(result)
            }
        }

        let hostingController = UIHostingController(rootView: sheetView)
        hostingController.modalPresentationStyle = .fullScreen

        sdk.initialize()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &sdk.cancellables)

        viewController.present(hostingController, animated: true)
    }

    // MARK: - Internal state

    /// Retained while the payment sheet is presented via `present(from:componentsSdkKey:onResult:)`.
    internal private(set) static var activeSDK: XenditComponents?

    internal let stateStore: SDKStateStore

    // These are `internal` (not `private`) so that private extensions in separate files
    // can access them without requiring `fileprivate`.
    let componentsSdkKey: String
    var parsedKey: ParsedSdkKey?
    var lastPaymentRequestId: String?
    let checkoutAPI: CheckoutAPI
    var eventListeners: [XenditEventListener] = []
    var poller = SessionPoller()
    var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    private init(componentsSdkKey: String) {
        self.componentsSdkKey = componentsSdkKey
        self.stateStore = SDKStateStore()
        self.checkoutAPI = CheckoutAPI()
        setupCardNumberObservation()
    }

    // MARK: - Instance API

    /// Loads the payment session and transitions the SDK to the `.active` state.
    ///
    /// Must complete successfully before the user can submit a payment. The returned
    /// publisher emits a single `Void` value on success or an error on failure.
    func initialize() -> AnyPublisher<Void, Error> {
        stateStore.sdkStatus = .loading

        let key: ParsedSdkKey
        do {
            key = try ParsedSdkKey.parse(componentsSdkKey)
        } catch {
            let message = error.localizedDescription
            stateStore.sdkStatus = .fatalError(message)
            dispatch(.fatalError(message: message))
            return Fail(error: error).eraseToAnyPublisher()
        }

        #if DEBUG
        Logger.setup(prefix: "XenditComponents")
        #endif

        parsedKey = key
        APIClient.shared.settings.apiUrl = key.baseURL.absoluteString

        return checkoutAPI.fetchSession(sessionAuthKey: key.sessionAuthKey)
            .mapError { $0 as Error }
            .flatMap { [weak self] response -> AnyPublisher<Void, Error> in
                guard let self else {
                    return Fail(error: URLError(.cancelled)).eraseToAnyPublisher()
                }
                guard response.session.mode == .components else {
                    let msg = "Session mode must be COMPONENTS"
                    self.stateStore.sdkStatus = .fatalError(msg)
                    self.dispatch(.fatalError(message: msg))
                    return Fail(
                        error: XenditAPIError.serverError(code: "INVALID_MODE", message: msg, content: nil)
                    ).eraseToAnyPublisher()
                }

                self.stateStore.rawSession = response.session
                self.stateStore.session = response.session.toModel()
                self.stateStore.businessName = response.business.name
                self.stateStore.customer = response.customer.toModel()
                self.stateStore.channels = response.channels.filter { $0.pmType == .cards || $0.pmType == .qrCode }
                self.stateStore.channelUiGroups = response.channelUiGroups
                
                switch response.session.status {
                case.completed:
                    self.dispatch(.sessionComplete)
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                case .canceled:
                    self.dispatch(.sessionCanceled)
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                case .expired:
                    self.dispatch(.sessionExpired)
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                case .active, .unknown:
                    break
                }
                
                self.stateStore.sdkStatus = .active
                self.dispatch(.initialized)
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .handleEvents(receiveCompletion: { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                let message = error.localizedDescription
                self?.stateStore.sdkStatus = .fatalError(message)
                let errorCode = (error as? APIClientError)?.errorCode
                self?.dispatch(.fatalError(message: message, errorCode: errorCode))
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Registers a listener that receives all SDK lifecycle and payment events.
    func addEventListener(_ listener: @escaping XenditEventListener) {
        eventListeners.append(listener)
    }

    /// Submits the currently selected channel with the filled form values.
    ///
    /// Requires `.active` SDK status, a selected channel, and a valid form.
    /// The publisher completes once the full submission flow — including any required
    /// user actions and backend polling — has finished.
    internal func submit() -> AnyPublisher<Void, Error> {
        guard stateStore.sdkStatus == .active else {
            return Fail(error: XenditAPIError.serverError(
                code: "SDK_NOT_ACTIVE", message: "SDK is not active", content: nil
            )).eraseToAnyPublisher()
        }
        guard let channel = stateStore.currentChannel else {
            return Fail(error: XenditAPIError.serverError(
                code: "NO_CHANNEL", message: "No payment channel selected", content: nil
            )).eraseToAnyPublisher()
        }
        guard let parsedKey, let session = stateStore.session else {
            return Fail(error: XenditAPIError.serverError(
                code: "NOT_INITIALIZED", message: "SDK not initialized", content: nil
            )).eraseToAnyPublisher()
        }

        stateStore.isSubmitting = true
        dispatch(.submissionBegin)

        return performSubmission(channel: channel, session: session, parsedKey: parsedKey)
            .flatMap { [weak self] result -> AnyPublisher<Void, Error> in
                guard let self else {
                    return Fail(error: URLError(.cancelled)).eraseToAnyPublisher()
                }
                return self.handleSubmissionResult(result, parsedKey: parsedKey)
            }
            .handleEvents(receiveCompletion: { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.stateStore.isSubmitting = false
                let strings = XenditStrings(locale: session.locale)
                if let clientError = error as? APIClientError,
                   clientError.type == .noInternet {
                    self?.dispatch(.submissionEnd(.init(
                        reason: "REQUEST_FAILED",
                        userErrorMessages: [
                            strings.string(for: .networkErrorTitle),
                            strings.string(for: .networkErrorSubtext)
                        ],
                        developerError: .init(type: .networkError, code: clientError.errorCode)
                    )))
                } else if let clientError = error as? APIClientError,
                          let backendError = clientError.backendError {
                    if let errorContent = backendError.errorContent {
                        self?.dispatch(.submissionEnd(.init(
                            reason: "REQUEST_FAILED",
                            userErrorMessages: [errorContent.title, errorContent.message1, errorContent.message2].compactMap { $0 },
                            developerError: .init(type: .failure, code: backendError.code)
                        )))
                    } else {
                        self?.dispatch(.submissionEnd(.init(
                            reason: "REQUEST_FAILED",
                            userErrorMessages: [
                                strings.string(for: .defaultErrorTitle),
                                backendError.message
                            ],
                            developerError: .init(type: .failure, code: backendError.code)
                        )))
                    }
                } else {
                    self?.dispatch(.submissionEnd(.init(
                        reason: "REQUEST_FAILED",
                        userErrorMessages: [
                            strings.string(for: .defaultErrorTitle),
                            strings.string(for: .defaultErrorMessage1),
                            strings.string(for: .defaultErrorMessage2)
                        ],
                        developerError: .init(type: .networkError, code: "NETWORK_ERROR")
                    )))
                }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Updates the active channel and resets all channel-specific form state.
    func setCurrentResponseChannel(_ channel: SessionResponse.Channel) {
        stateStore.currentChannel = channel
        stateStore.channelProperties = [:]
        stateStore.installmentPlans = nil
        stateStore.selectedInstallmentPlan = nil
        dispatchReadinessEvent(channelCode: channel.channelCode)
    }

    /// Persists updated form field values and notifies listeners of the current submission readiness.
    func updateChannelProperties(_ properties: ChannelProperties) {
        stateStore.channelProperties = properties
        guard let channel = stateStore.currentChannel else { return }
        dispatchReadinessEvent(channelCode: channel.channelCode)
    }

    // MARK: - Event dispatch

    func dispatch(_ event: XenditEvent) {
        eventListeners.forEach { $0(event) }
    }

    private func dispatchReadinessEvent(channelCode: String) {
        if stateStore.isFormValid {
            dispatch(.submissionReady(channelCode: channelCode))
        } else {
            dispatch(.submissionNotReady)
        }
    }
}
