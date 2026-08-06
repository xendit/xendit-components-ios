import SwiftUI
import XenditComponents

struct ContentView: View {
    @State private var sdkKey = "components_sdk_key here"
    @State private var selectedTheme: AppTheme = .default
    @State private var resultMessage: String?
    @State private var showingResult = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration")) {
                    Text("Paste your `components_sdk_key` from the Create Session response.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $sdkKey)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 120)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section(header: Text("Theme")) {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Button {
                        presentPaymentSheet()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Checkout with Xendit")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(sdkKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Xendit SDK Example")
            .alert("Payment Result", isPresented: $showingResult) {
                Button("OK") { }
            } message: {
                Text(resultMessage ?? "")
            }
        }
        .navigationViewStyle(.stack)
    }

    private func presentPaymentSheet() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        XenditComponents.initialize(appearance: selectedTheme.appearance)
        XenditComponents.present(
            from: rootViewController,
            componentsSdkKey: sdkKey.trimmingCharacters(in: .whitespacesAndNewlines),
//            merchantPreferredPaymentMethod: [.ewallet, .cards]
        ) { result in
            handleResult(result)
        }
    }

    private func handleResult(_ result: XenditPaymentResult) {
        switch result {
        case .success(let paymentRequestId, let channelCode):
            resultMessage = "Success!\nID: \(paymentRequestId)\nChannel: \(channelCode)"
        case .failed(let error):
            resultMessage = "Failed: \(error.message) (Code: \(error.code))"
        case .canceled:
            resultMessage = "Canceled: The session was terminated."
        case .expired:
            resultMessage = "Expired: The session timed out."
        case .dismissed:
            resultMessage = "Dismissed: User closed the sheet."
        }
        showingResult = true
    }
}

#Preview {
    ContentView()
}
