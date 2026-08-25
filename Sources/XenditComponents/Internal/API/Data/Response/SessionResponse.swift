//
//  SessionResponse.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/04/2026.
//

import Foundation

//Response from backend
enum SessionResponse {}

// MARK: - Response
extension SessionResponse {
    struct Response: Decodable {
        let session: Session
        let business: Business?
        let customer: Customer?
        let channels: [Channel]?
        let channelUiGroups: [ChannelUIGroup]?
        let digitalWallets: DigitalWallets?
        
        enum CodingKeys: String, CodingKey {
            case session, business, customer, channels
            case channelUiGroups = "channel_ui_groups"
            case digitalWallets = "digital_wallets"
        }
    }
}


// MARK: Business

extension SessionResponse {
    struct Business: Decodable {
        let name: String?
        let countryOfOperation: String?
        let merchantProfilePictureUrl: String?

        enum CodingKeys: String, CodingKey {
            case name
            case countryOfOperation = "country_of_operation"
            case merchantProfilePictureUrl = "merchant_profile_picture_url"
        }
    }
}

// MARK: Customer

extension SessionResponse {
    struct Customer: Codable, SnakeCaseEncodable {
        let type: String
        let id: String
        let email: String?
        let mobileNumber: String?
        let phoneNumber: String?
        let individualDetail: IndividualDetail?

        enum CodingKeys: String, CodingKey {
            case type, id, email
            case mobileNumber = "mobile_number"
            case phoneNumber = "phone_number"
            case individualDetail = "individual_detail"
        }
    }
}

// MARK: Individual Detail

extension SessionResponse.Customer {
    struct IndividualDetail: Codable {
        let givenNames: String
        let surname: String?

        enum CodingKeys: String, CodingKey {
            case givenNames = "given_names"
            case surname
        }
    }
}

// MARK: - Customer Mapping

extension SessionResponse.Customer {
    func toModel() -> Customer {
        Customer(
            id: id,
            type: .individual,
            email: email,
            mobileNumber: mobileNumber,
            individualDetail: individualDetail.map {
                Customer.IndividualDetail(
                    givenNames: $0.givenNames,
                    surname: $0.surname
                )
            }
        )
    }
}

// MARK: Channel UI Group

extension SessionResponse {
    struct ChannelUIGroup: Decodable {
        let id: String
        let label: String
        let iconUrl: String

        enum CodingKeys: String, CodingKey {
            case id, label
            case iconUrl = "icon_url"
        }
    }
}
