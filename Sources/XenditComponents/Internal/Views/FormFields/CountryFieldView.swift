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
    var a11yId: String = ""
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
            a11yIdTrigger: a11yId.isEmpty ? "" : XenditA11yIds.formDropdownPrefix + a11yId,
            a11yIdSheet: XenditA11yIds.countryPickerSheet,
            a11yIdClose: XenditA11yIds.countryPickerSheetClose,
            a11yIdSearch: XenditA11yIds.countryPickerSearch,
            a11yIdItemPrefix: XenditA11yIds.optionPrefix,
            onChanged: onChanged
        )
    }
}
