//
//  XenditActionWebView.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import SwiftUI
import WebKit

struct XenditWebView: UIViewRepresentable {
    private static let messageHandlerName = "xendit"

    let url: URL
    var iframeCapable: Bool = true
    var onChallengeCompleted: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        // Weak proxy prevents the strong-reference cycle:
        // WKUserContentController retains handlers strongly, which would
        // pin the Coordinator in memory and prevent proper teardown.
        userContentController.add(WeakMessageHandler(context.coordinator), name: Self.messageHandlerName)

        let config = WKWebViewConfiguration()
        config.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Guard against reloading on every SwiftUI re-render — reloading resets
        // the page and drops any in-flight postMessage calls.
        guard context.coordinator.loadedURL != url else { return }
        context.coordinator.loadedURL = url

        if iframeCapable {
            let baseURL = url.scheme.flatMap { scheme in
                url.host.map { host in URL(string: "\(scheme)://\(host)") }
            } ?? URL(string: "https://api.xendit.co")
            uiView.loadHTMLString(iframeHTML(for: url), baseURL: baseURL)
        } else {
            uiView.load(URLRequest(url: url))
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: messageHandlerName)
    }

    // MARK: - iframe HTML wrapper

    private func iframeHTML(for url: URL) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                html, body { margin: 0; padding: 0; }
                iframe { border: none; width: 100%; height: 100%; position: fixed; left: 0; top: 0; }
            </style>
            <script>
                window.addEventListener('message', function(e) {
                    try {
                        var payload = e.data;
                        var message = String(payload);
                        window.webkit.messageHandlers.\(Self.messageHandlerName).postMessage(message);
                    } catch (err) {
                        console.error('iOS bridge error', err);
                    }
                }, false);

                function handleIframeLoad(iframeElement) {
                    try {
                        window.webkit.messageHandlers.\(Self.messageHandlerName).postMessage(
                            JSON.stringify({ event: 'iframeLoad', url: iframeElement.src })
                        );
                    } catch (err) {
                        console.log('Load bridge error');
                    }
                }
            </script>
        </head>
        <body>
            <iframe src="\(url.absoluteString)" onload="handleIframeLoad(this)"></iframe>
        </body>
        </html>
        """
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: XenditWebView
        var loadedURL: URL?
        private var hasCompleted = false

        init(_ parent: XenditWebView) {
            self.parent = parent
        }

        // MARK: WKScriptMessageHandler

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let body = message.body as? String else {
                return
            }

            guard
                let data = body.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return }

            let type = json["type"] as? String

            if type == "xendit-iframe-action-complete" {
                emitOnce()
            }
        }

        private func emitOnce() {
            guard !hasCompleted else { return }
            hasCompleted = true
            DispatchQueue.main.async { self.parent.onChallengeCompleted() }
        }

        // MARK: WKNavigationDelegate

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            let url = navigationAction.request.url

            if let url,
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               components.queryItems?.first(where: { $0.name == "component_status" })?.value != nil {
                emitOnce()
            }

            decisionHandler(.allow)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        }
    }
}

// MARK: - Weak proxy

/// Breaks the strong-reference cycle imposed by WKUserContentController.
/// WKUserContentController retains script message handlers strongly; wrapping
/// the real handler in this proxy lets the Coordinator be deallocated normally.
private class WeakMessageHandler: NSObject, WKScriptMessageHandler {
    weak var handler: WKScriptMessageHandler?

    init(_ handler: WKScriptMessageHandler) {
        self.handler = handler
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}

// MARK: - Action wrapper

struct XenditActionWebView: View {
    let urlString: String
    let onDismiss: () -> Void
    var onChallengeCompleted: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Done") { onDismiss() }
                    .padding()
            }
            .background(Color(.systemGroupedBackground))

            if let url = URL(string: urlString) {
                XenditWebView(url: url, iframeCapable: true) {
                    onChallengeCompleted?() ?? onDismiss()
                }
            } else {
                Text("Invalid URL")
            }
        }
    }
}
