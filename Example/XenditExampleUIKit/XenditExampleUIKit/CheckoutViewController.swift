import UIKit
import XenditComponents

final class CheckoutViewController: UIViewController {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Paste your components_sdk_key from the Create Session response."
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let keyTextView: UITextView = {
        let tv = UITextView()
        tv.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var checkoutButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Checkout with Xendit"
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return button
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Xendit SDK Example"
        view.backgroundColor = .systemGroupedBackground
        setupLayout()

        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        [instructionLabel, keyTextView, checkoutButton, resultLabel].forEach {
            contentStack.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

            keyTextView.heightAnchor.constraint(equalToConstant: 140),
        ])
    }

    // MARK: - Actions

    @objc private func checkoutTapped() {
        let key = keyTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }

        resultLabel.isHidden = true

        XenditComponents.present(from: self, componentsSdkKey: key) { [weak self] result in
            self?.handleResult(result)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Result handling

    private func handleResult(_ result: XenditPaymentResult) {
        let message: String
        switch result {
        case .success(let paymentRequestId, let channelCode):
            message = "✓ Success\nID: \(paymentRequestId)\nChannel: \(channelCode)"
            resultLabel.textColor = .systemGreen
        case .failed(let error):
            message = "✗ Failed\n\(error.message) (\(error.code))"
            resultLabel.textColor = .systemRed
        case .canceled:
            message = "Canceled: The session was terminated."
            resultLabel.textColor = .secondaryLabel
        case .expired:
            message = "Expired: The session timed out."
            resultLabel.textColor = .secondaryLabel
        case .dismissed:
            message = "Dismissed: User closed the sheet."
            resultLabel.textColor = .secondaryLabel
        }

        resultLabel.text = message
        resultLabel.isHidden = false
    }
}
