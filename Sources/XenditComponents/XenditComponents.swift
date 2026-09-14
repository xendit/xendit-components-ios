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
/// To restrict and order which payment methods are shown, pass `merchantPreferredPaymentMethod`:
/// ```swift
/// XenditComponents.present(
///     from: viewController,
///     componentsSdkKey: "your-key",
///     merchantPreferredPaymentMethod: [.ewallet, .cards]
/// ) { result in ... }
/// ```
/// Only the specified types will appear, in the order listed. Pass `nil` (the default) to show
/// payment methods in the server's default order.
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
    ///   - merchantPreferredPaymentMethod: Optional list of payment method types to display.
    ///     When provided, only the listed types are shown and they appear in the given order.
    ///     Pass `nil` (the default) to show available payment methods in the server's order.
    ///   - onResult: Invoked on the main thread with the final payment outcome.
    public static func present(
        from viewController: UIViewController,
        componentsSdkKey: String,
        merchantPreferredPaymentMethod: [XenditPaymentMethod]? = nil,
        onResult: @escaping (XenditPaymentResult) -> Void
    ) {
        let sdk = XenditComponents(componentsSdkKey: componentsSdkKey, merchantPreferredPaymentMethod: merchantPreferredPaymentMethod)
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
    let merchantPreferredPaymentMethod: [XenditPaymentMethod]?
    var parsedKey: ParsedSdkKey?
    var lastPaymentRequestId: String?
    let checkoutAPI: CheckoutAPI
    var eventListeners: [XenditEventListener] = []
    var poller = SessionPoller()
    var applePayController: ApplePayController?
    var cancellables = Set<AnyCancellable>()

    // MARK: - Telemetry
    var telemetry: SessionTelemetry?
    var currentChannelTelemetryScope: SessionTelemetryScope?
    var channelGroupTelemetryScope: SessionTelemetryScope?
    var attemptTelemetryScope: SessionTelemetryScope?
    var attemptPRScope: SessionTelemetryScope?
    var actionTelemetryScope: SessionTelemetryScope?
    var firedFormInputKeys: Set<String> = []
    var sessionReachedTerminalState = false

    // MARK: - Initializer

    private init(componentsSdkKey: String, merchantPreferredPaymentMethod: [XenditPaymentMethod]? = nil) {
        self.componentsSdkKey = componentsSdkKey
        self.merchantPreferredPaymentMethod = merchantPreferredPaymentMethod
        self.stateStore = SDKStateStore()
        self.checkoutAPI = CheckoutAPI()
        setupCardNumberObservation()
        self.telemetry = SessionTelemetry(sdk: self)
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
            telemetry?.append(TelemetryEvents.loaded(success: false))
            return Fail(error: error).eraseToAnyPublisher()
        }

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
                    self.telemetry?.append(TelemetryEvents.loaded(success: false))
                    return Fail(
                        error: XenditAPIError.serverError(code: "INVALID_MODE", message: msg, content: nil)
                    ).eraseToAnyPublisher()
                }

                self.stateStore.rawSession = response.session
                self.stateStore.session = response.session.toModel()
                self.stateStore.businessName = response.business?.name
                self.stateStore.customer = response.customer?.toModel()
                let filtered = response.channels?.filter {
                    !$0.isDeprecated
                    && ($0.pmType == .cards
                    || $0.pmType == .qrCode
                    || $0.pmType == .ewallet
                    || $0.pmType == .virtualAccount
                    || $0.pmType == .bankTransfer
                    || $0.pmType == .onlineBanking
                    || $0.pmType == .directDebit
                    || $0.pmType == .overTheCounter)
                }
                let pairing = CombinedChannelsResult.combining(filtered)
                let allSelectableChannelCodes = pairing.channels.map { $0.channelCode }
                self.stateStore.channels = pairing.channels
                self.stateStore.channelVariants = pairing.variants
                self.stateStore.channelUiGroups = response.channelUiGroups ?? []
                self.stateStore.phoneCountryCode = response.session.country
                self.stateStore.digitalWallets = response.digitalWallets

                self.applyMerchantPreferences()

                switch response.session.status {
                case .completed:
                    self.telemetry?.appendAndPushScope(TelemetryEvents.loaded(success: true, channels: allSelectableChannelCodes))
                    self.dispatch(.sessionComplete)
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                case .canceled:
                    self.telemetry?.appendAndPushScope(TelemetryEvents.loaded(success: true, channels: allSelectableChannelCodes))
                    self.dispatch(.sessionCanceled)
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                case .expired:
                    self.telemetry?.appendAndPushScope(TelemetryEvents.loaded(success: true, channels: allSelectableChannelCodes))
                    self.dispatch(.sessionExpired)
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                case .pending:
                    self.telemetry?.appendAndPushScope(TelemetryEvents.loaded(success: true, channels: allSelectableChannelCodes))
                    self.telemetry?.append(TelemetryEvents.pending(success: true))
                case .active, .unknown:
                    self.telemetry?.appendAndPushScope(TelemetryEvents.loaded(success: true, channels: allSelectableChannelCodes))
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
                self?.telemetry?.append(TelemetryEvents.loaded(success: false))
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func presentApplePay() {
        guard let applePay = stateStore.digitalWallets?.applePay,
              let session = stateStore.session,
              let parsedKey else { return }
        let controller = ApplePayController(
            sdk: self,
            applePayData: applePay,
            session: session,
            parsedKey: parsedKey
        )
        applePayController = controller
        controller.digitalWalletTelemetryScope = telemetry?.appendAndPushScope(
            TelemetryEvents.digitalWalletBegin(success: true, digitalWallet: "APPLE_PAY")
        )
        controller.present()
    }

    private func applyMerchantPreferences() {
        let preferred: [SessionResponse.Channel.PaymentMethod] = (merchantPreferredPaymentMethod ?? []).map {
            switch $0 {
            case .cards:          return .cards
            case .ewallet:        return .ewallet
            case .qrCode:         return .qrCode
            case .bankTransfer:   return .bankTransfer
            case .onlineBanking:  return .onlineBanking
            case .directDebit:    return .directDebit
            case .virtualAccount: return .virtualAccount
            case .overTheCounter: return .overTheCounter
            }
        }
        guard !preferred.isEmpty else { return }

        stateStore.channels = stateStore.channels.filter {
            $0.pmType.map { preferred.contains($0) } ?? false
        }

        let channelsByGroup = Dictionary(grouping: stateStore.channels, by: \.uiGroup)
        stateStore.channelUiGroups = stateStore.channelUiGroups.sorted { a, b in
            let aIdx = channelsByGroup[a.id]?.first?.pmType.flatMap { preferred.firstIndex(of: $0) } ?? Int.max
            let bIdx = channelsByGroup[b.id]?.first?.pmType.flatMap { preferred.firstIndex(of: $0) } ?? Int.max
            return aIdx < bIdx
        }
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
        attemptTelemetryScope = telemetry?.appendAndPushScope(TelemetryEvents.attemptBegin(success: true))

        let effectiveChannel: SessionResponse.Channel
        if stateStore.savePaymentMethod,
           let variants = stateStore.channelVariants[channel.channelCode] {
            effectiveChannel = variants.saveChannel
        } else {
            effectiveChannel = channel
        }

        return performSubmission(channel: effectiveChannel, session: session, parsedKey: parsedKey)
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
                    let code = clientError.errorCode
                    self?.telemetry?.append(TelemetryEvents.attemptError(success: false, errorCode: code))
                    self?.telemetry?.append(TelemetryEvents.attemptDiscard(success: false, failureCode: code))
                    if let scope = self?.attemptTelemetryScope { self?.telemetry?.popScope(scope) }
                    self?.attemptTelemetryScope = nil
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
                    let code = backendError.code
                    self?.telemetry?.append(TelemetryEvents.attemptError(success: false, errorCode: code))
                    self?.telemetry?.append(TelemetryEvents.attemptDiscard(success: false, failureCode: code))
                    if let scope = self?.attemptTelemetryScope { self?.telemetry?.popScope(scope) }
                    self?.attemptTelemetryScope = nil
                    if let errorContent = backendError.errorContent {
                        self?.dispatch(.submissionEnd(.init(
                            reason: "REQUEST_FAILED",
                            userErrorMessages: [errorContent.title, errorContent.message1, errorContent.message2].compactMap { $0 },
                            developerError: .init(type: .failure, code: code)
                        )))
                    } else {
                        self?.dispatch(.submissionEnd(.init(
                            reason: "REQUEST_FAILED",
                            userErrorMessages: [
                                strings.string(for: .defaultErrorTitle),
                                backendError.message
                            ],
                            developerError: .init(type: .failure, code: code)
                        )))
                    }
                } else {
                    self?.telemetry?.append(TelemetryEvents.attemptError(success: false, errorCode: "NETWORK_ERROR"))
                    self?.telemetry?.append(TelemetryEvents.attemptDiscard(success: false, failureCode: "NETWORK_ERROR"))
                    if let scope = self?.attemptTelemetryScope { self?.telemetry?.popScope(scope) }
                    self?.attemptTelemetryScope = nil
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
        if let prev = currentChannelTelemetryScope { telemetry?.popScope(prev) }
        currentChannelTelemetryScope = telemetry?.appendAndPushScope(
            TelemetryEvents.channel(success: true, paymentChannel: channel.channelCode)
        )
        firedFormInputKeys = []
        stateStore.currentChannel = channel
        stateStore.channelProperties = [:]
        stateStore.installmentPlans = nil
        stateStore.selectedInstallmentPlan = nil
        dispatchReadinessEvent(channelCode: channel.channelCode)
    }

    /// Persists updated form field values and notifies listeners of the current submission readiness.
    func updateChannelProperties(_ properties: ChannelProperties) {
        for key in properties.keys where !firedFormInputKeys.contains(key) {
            firedFormInputKeys.insert(key)
            telemetry?.append(TelemetryEvents.channelFormInput(success: true, fieldName: key))
        }
        stateStore.channelProperties = properties
        guard let channel = stateStore.currentChannel else { return }
        dispatchReadinessEvent(channelCode: channel.channelCode)
    }

    func handleChannelGroupTapped(_ groupName: String) {
        if let prev = channelGroupTelemetryScope { telemetry?.popScope(prev) }
        let groupChannelCodes = stateStore.channels
            .filter { $0.uiGroup == groupName }
            .map { $0.channelCode }
        channelGroupTelemetryScope = telemetry?.appendAndPushScope(
            TelemetryEvents.channelGroup(success: true, groupName: groupName, channels: groupChannelCodes)
        )
    }

    // MARK: - Event dispatch

    func dispatch(_ event: XenditEvent) {
        switch event {
        case .sessionComplete:
            sessionReachedTerminalState = true
            telemetry?.append(TelemetryEvents.end(success: true, status: "succeeded"))
        case .sessionCanceled:
            sessionReachedTerminalState = true
            telemetry?.append(TelemetryEvents.end(success: false, status: "canceled"))
        case .sessionExpired:
            sessionReachedTerminalState = true
            telemetry?.append(TelemetryEvents.end(success: false, status: "expired"))
        default:
            break
        }
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
