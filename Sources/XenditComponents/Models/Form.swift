//
//  Form.swift
//  XenditComponents
//
//  Created by Ahmad X on 13/04/2026.
//

import Foundation

// Converted data from Response for UI to use
enum Form {}

extension Form {
    struct Page: Hashable {
        let sections: [Section]
    }
}

extension Form {
    struct Section: Hashable, Identifiable {
        let id: String
        let title: String?
        let isHidden: Bool
        let components: [Component]
    }
}


extension Form {
    enum Component: Hashable {
        // Input
        case inputField(field: InputField)

        // Display
        ///For Channel.FormField that have span = 1next to each other in the array
        case row(components: [Form.Component], alignment: VerticalAlignment, spacing: CGFloat)
    }
}

//Input field
extension Form {
    struct InputField: Hashable, Identifiable {
        let id: String
        let type: InputType
        let label: String?
        let placeholder: String?
        let required: Bool
        let isDisabled: Bool
        let initialValue: String?
        let channelProperty: ChannelProperty
        let flags: Flags
        /// When true: hide this field's label and collapse the gap between this field and the previous one.
        let join: Bool
    }
    
    enum InputType: Hashable {
        // Text type
        case text(minLength: Int?, maxLength: Int, numeric: Bool?, regexValidators: [RegexValidator]?)
        case creditCardNumber(brands: [String])
        case creditCardExpiry
        case creditCardCvn
        case email
        case postalCode
        
        // Selection type
        case dropdown(options: [DropdownOption])
        case phoneNumber
        case installmentPlan
        /// Save payment method checkbox.
        /// - isChecked: initial checked state (true when FORCED, false when OPTIONAL)
        /// - isEnabled: whether the user can toggle the checkbox (false when FORCED)
        case checkbox(isChecked: Bool, isEnabled: Bool)
        
        // Special type
        case country // Can be either text or selection
        case province // Can be either text or selection

        //Uknown
        case unknown(String)
    }
    
    enum ChannelProperty: Hashable {
        case single(String)
        case multiple([String])

        var keys: [String] {
            switch self {
            case .single(let key): return [key]
            case .multiple(let keys): return keys
            }
        }

        var primaryKey: String {
            keys[0]
        }
    }

    
    struct RegexValidator: Hashable {
        let regex: String
        let message: String
    }
    
    struct DropdownOption: Hashable {
        let label: String
        let subtitle: String?
        let iconUrl: String?
        let value: String
    }
    
    struct Flags: Hashable {
        let requireBillingInformation: Bool?
    }
    
    enum VerticalAlignment: String, Decodable, Hashable {
        case center
        case top
        case bottom
    }
}


