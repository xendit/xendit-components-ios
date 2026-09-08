//
//  DropdownFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 01/05/2026.
//

import SwiftUI

struct DropdownFieldView: View {
    let label: String
    let placeholder: String
    let options: [Option]
    @Binding var value: String
    var isDisabled: Bool = false
    var a11yIdAnchor: String = ""
    var a11yIdSheet: String = ""
    var a11yIdItemPrefix: String = ""
    var onChanged: (() -> Void)?
    var showIconDivider: Bool = false
    var iconSize: CGSize = CGSize(width: 34, height: 24)


    struct Option: Identifiable {
        var id: String { value }
        let label: String
        let value: String
        let subtitle: String?
        var iconUrl: String? = nil
        var isDisabled: Bool = false
    }

    var body: some View {
        BottomSheetPickerFieldView(
            label: label,
            placeholder: placeholder,
            options: options.map {
                BottomSheetPickerFieldView.PickerOption(
                    label: $0.label,
                    subtitle: $0.subtitle,
                    value: $0.value,
                    iconUrl: $0.iconUrl,
                    isDisabled: $0.isDisabled
                )
            },
            value: $value,
            isDisabled: isDisabled,
            showIconDivider: showIconDivider,
            iconSize: iconSize,
            iconClipShape: .rectangle,
            a11yIdTrigger: a11yIdAnchor,
            a11yIdSheet: a11yIdSheet,
            a11yIdItemPrefix: a11yIdItemPrefix,
            onChanged: onChanged
        )
    }
}
