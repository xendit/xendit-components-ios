// ProvinceFieldView — renders a searchable bottom-sheet picker for supported countries
// (US, CA, GB) and a plain text field for all others.
// provinces is a computed property so it always reflects selectedCountry on every render;
// ProvinceProvider's internal cache makes repeated calls essentially free.
import SwiftUI

struct ProvinceFieldView: View {
    let label: String
    let placeholder: String
    let selectedCountry: String
    @Binding var value: String
    var isDisabled: Bool = false
    var a11yId: String = ""
    var onChanged: (() -> Void)?

    /// Always current — recomputed from selectedCountry on every render.
    private var provinces: [Province]? {
        ProvinceProvider.provinces(for: selectedCountry)
    }

    // MARK: - Body

    var body: some View {
        XenditLabeledField(label: label) {
            Group {
                if let provinces = provinces, !provinces.isEmpty {
                    BottomSheetPickerFieldView(
                        label: "",
                        placeholder: placeholder,
                        options: provinces.map {
                            BottomSheetPickerFieldView.PickerOption(label: $0.name, subtitle: nil, value: $0.code)
                        },
                        value: $value,
                        isDisabled: isDisabled,
                        searchEnabled: true,
                        a11yIdTrigger: a11yId.isEmpty ? "" : XenditA11yIds.formDropdownPrefix + a11yId,
                        a11yIdSheet: XenditA11yIds.provincePickerSheet,
                        a11yIdClose: XenditA11yIds.provincePickerSheetClose,
                        a11yIdSearch: XenditA11yIds.provincePickerSearch,
                        a11yIdItemPrefix: XenditA11yIds.optionPrefix,
                        onChanged: onChanged
                    )
                    .transition(.opacity)
                } else {
                    XenditTextField(
                        text: $value,
                        placeholder: placeholder,
                        isDisabled: isDisabled,
                        uiFont: XenditComponents.appearance.fontFamily?.regular,
                        onChanged: onChanged
                    )
                    .padding(.horizontal, Spacing.s3)
                    .frame(height: 44)
                    .xenditFieldBorder()
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: provinces != nil)
        }
        .onChange(of: selectedCountry) { _ in
            // Clear the stored province when country switches so the new picker
            // starts empty rather than carrying over a code from the old country.
            value = ""
        }
    }
}
