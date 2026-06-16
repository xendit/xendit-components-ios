//
//  XenditSheetView.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/05/2026.
//

import SwiftUI
import Combine
import UIKit

struct XenditSheetView: View {
    private let sdk: XenditComponents
    @ObservedObject var stateStore: SDKStateStore
    let onResult: (XenditPaymentResult) -> Void

    init(sdk: XenditComponents, onResult: @escaping (XenditPaymentResult) -> Void) {
        self.sdk = sdk
        self.stateStore = sdk.stateStore
        self.onResult = onResult
    }

    @State private var cancellables = Set<AnyCancellable>()
    @State private var errorMessage: String?
    @State private var submissionAlert: SubmissionAlert?
    @State private var didSetupListeners = false

    private struct SubmissionAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String?
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView

                switch stateStore.sdkStatus {
                case .active:
                    activeView
                case .fatalError(let message):
                    errorView(message: message)
                case .idle, .loading:
                    XenditSkeletonView()
                }
            }

            if (stateStore.isSubmitting || stateStore.isPolling) && stateStore.activeAction == nil && stateStore.awaitingPaymentAction == nil {
                submitLoadingOverlay
            }
            
            if let awaitingAction = stateStore.awaitingPaymentAction {
                AwaitingPaymentView(
                    action: awaitingAction,
                    channelName: stateStore.currentChannel?.brandName ?? "",
                    channelLogoUrl: stateStore.currentChannel?.brandLogoUrl,
                    locale: stateStore.session?.locale ?? "en",
                    onClose: {
                        stateStore.awaitingPaymentAction = nil
                        stateStore.isPolling = false
                        stateStore.isSubmitting = false
                        sdk.poller.stopPolling()
                    }
                )
                .ignoresSafeArea()
            }
        }
        .background(XenditComponents.appearance.resolvedBackground)
        .alert(item: $submissionAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: stateStore.pendingDeeplinkUrl) { url in
            guard let url else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            stateStore.pendingDeeplinkUrl = nil
            stateStore.awaitingPaymentAction = .deeplink
        }
        .onAppear {
            Country.warmUp()
            guard !didSetupListeners else { return }
            didSetupListeners = true
            setupEventListeners()
        }
    }

    private var headerView: some View {
        HStack(spacing: Spacing.s4) {
            Button(action: { onResult(.dismissed) }) {
                Image("xdt_arrow_left_24", bundle: .module)
            }
            Text(headerTitle)
                .font(.headingH3)
            Spacer()
        }
        .padding(Spacing.s4)
    }

    private var submitLoadingOverlay: some View {
        XenditLoadingView()
    }

    private var activeView: some View {
        VStack(spacing: 0) {
            ScrollView {
                XenditChannelPickerView(sdk: sdk)
            }

            footerView
        }
        .fullScreenCover(item: $stateStore.activeAction) { action in
            if action.type == .redirectCustomer {
                XenditActionWebView(urlString: action.value, strings: strings) {
                    resumePolling()
                }
            } else if action.type == .presentToCustomer {
                XenditQrView(
                    action: action,
                    businessName: stateStore.businessName,
                    channelLogoUrl: stateStore.currentChannel?.brandLogoUrl,
                    amount: stateStore.session?.amount,
                    currency: stateStore.session?.currency,
                    locale: stateStore.session?.locale ?? "en",
                    onDismiss: {
                        resumePolling()
                    },
                    onPaymentMade: {
                        sdk.simulatePaymentIfNeeded()
                            .sink(receiveCompletion: { _ in
                                resumePolling()
                            }, receiveValue: { _ in })
                            .store(in: &cancellables)
                    }
                )

            }
        }
    }

    private var footerView: some View {
        VStack(spacing: 12) {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: {
                errorMessage = nil
                cancellables.removeAll()
                sdk.submit()
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                    .store(in: &cancellables)
            }) {
                HStack(spacing: Spacing.s1) {
                    Text(payButtonLabel)
                        .font(.bodyEmphasized)
                    if !stateStore.isSubmitting {
                        Image("xdt_arrow_right_20_white", bundle: .module)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(isPayButtonDisabled ? XenditComponents.appearance.resolvedDisabled : XenditComponents.appearance.resolvedPrimary)
                .foregroundColor(.white)
                .cornerRadius(XenditComponents.appearance.resolvedRadius)
            }
            .disabled(isPayButtonDisabled)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text("Initialization Failed")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Close") {
                onResult(.dismissed)
            }
            .padding()
            Spacer()
        }
    }

    private var strings: XenditStrings {
        XenditStrings(locale: stateStore.session?.locale ?? "en")
    }

    private var payButtonLabel: String {
        if stateStore.isSubmitting {
            return "Processing..."
        }

        if stateStore.session?.sessionType == .save {
            return strings.string(for: .paymentMethodsSubmitAddPaymentMethod)
        }

        return strings.string(for: .paymentMethodsSubmitPay)
    }

    private var headerTitle: String {
        strings.string(for: .paymentMethodsHeader)
    }

    private var isPayButtonDisabled: Bool {
        !stateStore.isFormValid || stateStore.isSubmitting
    }

    private func setupEventListeners() {
        sdk.addEventListener { event in
            switch event {
            case .sessionComplete:
                if let session = stateStore.session {
                    onResult(.success(paymentRequestId: session.id, channelCode: stateStore.currentChannel?.channelCode ?? ""))
                }
            case .sessionCanceled:
                onResult(.canceled)
            case .sessionExpired:
                onResult(.expired)
            case .fatalError(let message, let errorCode):
                onResult(.failed(error: .init(code: errorCode ?? "FATAL_ERROR", message: message)))
            case .submissionEnd(let payload):
                let messages = payload.userErrorMessages
                if !messages.isEmpty {
                    stateStore.isSubmitting = false
                    submissionAlert = SubmissionAlert(
                        title: messages[0],
                        message: messages.count > 1 ? messages[1] : nil
                    )
                } else {
                    onResult(.failed(error: .init(code: payload.developerError.code, message: payload.developerError.code)))
                }
            default:
                break
            }
        }
    }
    
    private func resumePolling() {
        stateStore.activeAction = nil
        stateStore.isSubmitting = false
        if !sdk.poller.isPolling {
            stateStore.isPolling = true
        }
        sdk.poller.stopPolling()
        sdk.poller.resumePolling()
    }
}
