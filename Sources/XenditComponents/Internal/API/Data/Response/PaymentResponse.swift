//
//  PaymentResponse.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/04/2026.
//

import Foundation

enum PaymentResponse {}

//MARK: - Action
extension PaymentResponse {
    enum Action: Decodable {
        case presentToCustomer(PresentToCustomerData)
        case redirectCustomer(RedirectCustomerData)
        case apiPostRequest(ApiPostRequestData)
        /// Received when the backend introduces an action type not yet known to this SDK version.
        /// The SDK ignores unknown actions rather than crashing.
        case unknown

        enum CodingKeys: String, CodingKey {
            case type
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "PRESENT_TO_CUSTOMER":
                self = .presentToCustomer(try PresentToCustomerData(from: decoder))
            case "REDIRECT_CUSTOMER":
                self = .redirectCustomer(try RedirectCustomerData(from: decoder))
            case "API_POST_REQUEST":
                self = .apiPostRequest(try ApiPostRequestData(from: decoder))
            default:
                Logger("PaymentResponse.Action").warning("Unknown action type '\(type)' — ignoring")
                self = .unknown
            }
        }
    }
}

extension PaymentResponse.Action {
    struct PresentToCustomerData: Decodable {
        let descriptor: PresentDescriptor
        let value: String
        let actionTitle: String
        let actionSubtitle: String
        let actionGraphic: String
        let instructions: [PaymentResponse.InstructionsTab]?

        enum PresentDescriptor: String, Decodable {
            case paymentCode = "PAYMENT_CODE"
            case qrString = "QR_STRING"
            case virtualAccountNumber = "VIRTUAL_ACCOUNT_NUMBER"
            /// Received when the backend introduces a descriptor not yet known to this SDK version.
            case unknown

            init(from decoder: Decoder) throws {
                let raw = try decoder.singleValueContainer().decode(String.self)
                self = Self(rawValue: raw) ?? .unknown
            }
        }

        enum CodingKeys: String, CodingKey {
            case descriptor, value, instructions
            case actionTitle = "action_title"
            case actionSubtitle = "action_subtitle"
            case actionGraphic = "action_graphic"
        }
    }
}

extension PaymentResponse.Action {
    struct RedirectCustomerData: Decodable {
        let descriptor: RedirectDescriptor
        let value: String
        let iframeCapable: Bool?

        enum RedirectDescriptor: String, Decodable {
            case webUrl = "WEB_URL"
            case deeplinkUrl = "DEEPLINK_URL"
            case webGooglePaylink = "WEB_GOOGLE_PAYLINK"
            /// Received when the backend introduces a descriptor not yet known to this SDK version.
            case unknown

            init(from decoder: Decoder) throws {
                let raw = try decoder.singleValueContainer().decode(String.self)
                self = Self(rawValue: raw) ?? .unknown
            }
        }

        enum CodingKeys: String, CodingKey {
            case descriptor, value
            case iframeCapable = "iframe_capable"
        }
    }
}

extension PaymentResponse.Action {
    struct ApiPostRequestData: Decodable {
        let descriptor: ApiDescriptor
        let value: String
        let otp: OtpData?

        struct OtpData: Decodable {
            let title: String
            let instructions: String
        }

        enum ApiDescriptor: String, Decodable {
            case capturePayment = "CAPTURE_PAYMENT"
            case validateOtp = "VALIDATE_OTP"
            case resendOtp = "RESEND_OTP"
            /// Received when the backend introduces a descriptor not yet known to this SDK version.
            case unknown

            init(from decoder: Decoder) throws {
                let raw = try decoder.singleValueContainer().decode(String.self)
                self = Self(rawValue: raw) ?? .unknown
            }
        }
    }
}

// MARK: InstructionsTab

extension PaymentResponse {
    struct InstructionsTab: Decodable {
        let title: String
        let content: [InstructionsContent]
    }

    // MARK: - InstructionsContent (The Mixed Array Wrapper)
    enum InstructionsContent: Decodable {
        case step(InstructionsStep)
        case nested([InstructionsContentItem])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let step = try? container.decode(InstructionsStep.self) {
                self = .step(step)
            } else if let nested = try? container.decode([InstructionsContentItem].self) {
                self = .nested(nested)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid content format")
            }
        }
    }

    enum InstructionsContentItem: Decodable {
        case string(String)
        case step(InstructionsStep)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) {
                self = .string(str)
            } else if let step = try? container.decode(InstructionsStep.self) {
                self = .step(step)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid item in nested content")
            }
        }
    }

    // MARK: - InstructionsStep
    enum InstructionsStep: Decodable {
        case text(text: String)
        case image(src: String, height: Double, alt: String?)
        case bullets(items: [String])
        case form(heading: String?, fields: [FormField])
        case table(headers: [String], rows: [[String]])
        /// Received when the backend introduces a step type not yet known to this SDK version.
        case unknown(rawType: String)

        struct FormField: Decodable {
            let label: String
            let value: String
        }

        enum CodingKeys: String, CodingKey {
            case type, text, src, height, alt, items, heading, fields, headers, rows
        }

       init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "text":
                let text = try container.decode(String.self, forKey: .text)
                self = .text(text: text)
            case "image":
                let src = try container.decode(String.self, forKey: .src)
                let height = try container.decode(Double.self, forKey: .height)
                let alt = try container.decodeIfPresent(String.self, forKey: .alt)
                self = .image(src: src, height: height, alt: alt)
            case "bullets":
                let items = try container.decode([String].self, forKey: .items)
                self = .bullets(items: items)
            case "form":
                let heading = try container.decodeIfPresent(String.self, forKey: .heading)
                let fields = try container.decode([FormField].self, forKey: .fields)
                self = .form(heading: heading, fields: fields)
            case "table":
                let headers = try container.decode([String].self, forKey: .headers)
                let rows = try container.decode([[String]].self, forKey: .rows)
                self = .table(headers: headers, rows: rows)
            default:
                Logger("PaymentResponse.InstructionsStep").warning("Unknown step type '\(type)' — skipping")
                self = .unknown(rawType: type)
            }
        }
    }
}

extension PaymentResponse {
    enum PaymentType: String, Codable {
        case pay = "PAY"
        case payAndSave = "PAY_AND_SAVE"
        case reusablePaymentCode = "REUSABLE_PAYMENT_CODE"
        /// Received when the backend introduces a payment type not yet known to this SDK version.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }
}
