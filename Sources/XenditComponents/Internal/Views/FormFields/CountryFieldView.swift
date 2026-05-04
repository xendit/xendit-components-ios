//
//  CountryFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 01/05/2026.
//

import SwiftUI

struct CountryFieldView: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    var isDisabled: Bool = false
    var onChanged: (() -> Void)?

    private static let options: [BottomSheetPickerFieldView.PickerOption] = Country.countries.map {
        BottomSheetPickerFieldView.PickerOption(label: $0.name, subtitle: nil, value: $0.code, iconUrl: $0.flagUrl)
    }

    var body: some View {
        BottomSheetPickerFieldView(
            label: label,
            placeholder: placeholder,
            options: Self.options,
            value: $value,
            isDisabled: isDisabled,
            searchEnabled: true,
            onChanged: onChanged
        )
    }
}
