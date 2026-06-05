//
//  ChannelFormView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

struct ChannelFormView: View {
    let channel: SessionResponse.Channel
    let session: Session
    let locale: String
    @ObservedObject var stateStore: SDKStateStore
    @Binding var channelProperties: ChannelProperties
    var onPropertiesChanged: ((ChannelProperties) -> Void)?

    // Cached to avoid re-running parse() (which allocated new objects) on every render.
    // Recomputed only when channel or allowSavePaymentMethod actually changes.
    @State private var formPage: Form.Page = Form.Page(sections: [])
    @State private var fieldErrors: [String: String] = [:]

    private var detectedCardType: CreditCardType? {
        guard let scheme = stateStore.cardDetails?.schemes.first else { return nil }
        return CreditCardType(rawValue: scheme)
    }

    private var showBillingDetails: Bool {
        stateStore.cardDetails?.requireBillingInformation ?? false
    }

    private var allowSavePaymentMethod: SessionResponse.Session.AllowSavePaymentMethod? {
        switch session.allowSavePaymentMethod {
        case .disabled: return .disabled
        case .optional: return .optional
        case .forced: return .forced
        case nil: return nil
        }
    }

    var body: some View {
        VStack(spacing: Spacing.s6) {
            ForEach(formPage.sections) { section in
                if !section.isHidden && hasVisibleComponent(in: section) {
                    sectionView(section)
                }
            }
        }
        .onAppear {
            formPage = channel.parse(allowSavePaymentMethod: allowSavePaymentMethod)
        }
        .onChange(of: channel.channelCode) { _ in
            formPage = channel.parse(allowSavePaymentMethod: allowSavePaymentMethod)
        }
        .onChange(of: session.allowSavePaymentMethod) { _ in
            formPage = channel.parse(allowSavePaymentMethod: allowSavePaymentMethod)
        }
    }

    // MARK: - Section & Component rendering

    @ViewBuilder
    private func sectionView(_ section: Form.Section) -> some View {
        let groups = renderGroups(for: section.components)
        VStack(alignment: .leading, spacing: Spacing.s3) {
            if let title = section.title, hasVisibleComponent(in: section) {
                Text(title)
                    .font(.labelLgRegular)
                    .foregroundColor(.Text.default)
            }
            ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                switch group {
                case .standalone(let comp):
                    componentView(comp)
                        .padding(.top, index > 0 ? Spacing.s3 : 0)
                case .joined(let comps):
                    joinedGroupView(comps)
                }
            }
        }
    }

    /// Groups components into standalone items and joined runs.
    /// A run starts at the first non-joined component and collects all immediately following joined components.
    private func renderGroups(for components: [Form.Component]) -> [RenderGroup] {
        var result: [RenderGroup] = []
        var i = 0
        while i < components.count {
            let comp = components[i]
            var group = [comp]
            i += 1
            while i < components.count && isJoined(components[i]) {
                group.append(components[i])
                i += 1
            }
            let isAllJoinedRow: Bool
            if case .row(let rowComps, _, _) = comp {
                isAllJoinedRow = !rowComps.isEmpty && rowComps.allSatisfy { isJoined($0) }
            } else {
                isAllJoinedRow = false
            }
            result.append((group.count > 1 || isAllJoinedRow) ? .joined(group) : .standalone(comp))
        }
        return result
    }

    private func isJoined(_ component: Form.Component) -> Bool {
        switch component {
        case .inputField(let field): return field.join
        case .row(let comps, _, _):
            if case .inputField(let f) = comps.first { return f.join }
            return false
        }
    }

    /// Renders a run of joined components as a single grouped card with internal dividers.
    /// Errors from individual fields are suppressed inline; the first error is shown below the card.
    @ViewBuilder
    private func joinedGroupView(_ components: [Form.Component]) -> some View {
        let a = XenditComponents.appearance
        let defaultBorderColor = a.resolvedBorder
        let dangerColor = a.resolvedDanger
        let cornerRadius = a.resolvedRadius
        let visible = components.filter { comp -> Bool in
            if case .inputField(let f) = comp { return shouldShow(f) }
            if case .row(let subs, _, _) = comp {
                return subs.contains { sub in
                    if case .inputField(let f) = sub { return shouldShow(f) }
                    return true
                }
            }
            return true
        }
        let fieldIds = components.flatMap { comp -> [String] in
            switch comp {
            case .inputField(let f): return [f.id]
            case .row(let subs, _, _):
                return subs.compactMap { sub -> String? in
                    guard case .inputField(let f) = sub else { return nil }
                    return f.id
                }
            }
        }
        let firstError = fieldIds.compactMap { fieldErrors[$0] }.first
        let activeBorderColor = firstError != nil ? dangerColor : defaultBorderColor
        if !visible.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                VStack(spacing: 0) {
                    ForEach(Array(visible.enumerated()), id: \.offset) { idx, comp in
                        if idx > 0 {
                            Rectangle().fill(activeBorderColor).frame(height: 1)
                        }
                        inJoinedGroupComponentView(comp, dividerColor: activeBorderColor)
                            .frame(maxWidth: .infinity)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(activeBorderColor, lineWidth: 1))
                .environment(\.xenditHideFieldBorder, true)
                if let error = firstError {
                    Text(error)
                        .font(InterFont.captionRegular)
                        .foregroundColor(dangerColor)
                }
            }
        }
    }

    /// Renders a single component inside a joined group (no individual border; rows get a vertical divider).
    @ViewBuilder
    private func inJoinedGroupComponentView(_ component: Form.Component, dividerColor: Color) -> some View {
        switch component {
        case .inputField(let field):
            if shouldShow(field) {
                fieldView(for: field)
            }
        case .row(let comps, let alignment, _):
            let visible = comps.filter { sub -> Bool in
                if case .inputField(let f) = sub { return shouldShow(f) }
                return true
            }
            if !visible.isEmpty {
                HStack(alignment: alignment.verticalAlignment, spacing: 0) {
                    ForEach(Array(visible.enumerated()), id: \.offset) { idx, comp in
                        if idx > 0 {
                            Rectangle()
                                .fill(dividerColor)
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                        }
                        if case .inputField(let field) = comp {
                            fieldView(for: field)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func componentView(_ component: Form.Component) -> some View {
        switch component {
        case .inputField(let field):
            if shouldShow(field) {
                fieldView(for: field)
                    .frame(maxWidth: .infinity)
            }
        case .row(let components, let alignment, let spacing):
            let visible = components.filter { comp in
                if case .inputField(let f) = comp { return shouldShow(f) }
                return true
            }
            if !visible.isEmpty {
                HStack(alignment: alignment.verticalAlignment, spacing: spacing) {
                    ForEach(Array(visible.enumerated()), id: \.offset) { _, comp in
                        AnyView(componentView(comp))
                            .frame(maxWidth: .infinity)
//                            .environment(\.xenditHideFieldBorder, true)
                    }
                }
            }
        }
    }

    private func hasVisibleComponent(in section: Form.Section) -> Bool {
        section.components.contains { component in
            switch component {
            case .inputField(let field):
                return shouldShow(field)
            case .row(let comps, _, _):
                return comps.contains {
                    guard case .inputField(let f) = $0 else { return true }
                    return shouldShow(f)
                }
            }
        }
    }

    private func shouldShow(_ field: Form.InputField) -> Bool {
        if case .installmentPlan = field.type {
            guard let plans = stateStore.installmentPlans, !plans.isEmpty else { return false }
        }
        if field.flags.requireBillingInformation == true && !showBillingDetails { //NOTE: This should be handle in the payment type object
            return false
        }
        return true
    }

    // MARK: - Field view with binding

    private func fieldView(for field: Form.InputField) -> some View {
        let keys = field.channelProperty.keys
        let fieldMapper = mapper(for: field)

        let binding: Binding<String>
        if case .checkbox(let isChecked, _) = field.type {
            // Checkbox binds directly to stateStore.savePaymentMethod
            binding = Binding(
                get: { self.stateStore.savePaymentMethod ? "true" : "false" },
                set: { self.stateStore.savePaymentMethod = $0 == "true" }
            )
            // Seed initial savePaymentMethod state from the parsed isChecked
            _ = isChecked // value used on appear via CheckboxFieldView.onAppear
        } else {
            binding = Binding(
                get: { fieldMapper.getValue(from: self.channelProperties, keys: keys, initialValue: field.initialValue) },
                set: { newValue in
                    fieldMapper.setValue(newValue, into: &self.channelProperties, keys: keys)
                    self.onPropertiesChanged?(self.channelProperties)
                }
            )
        }

        return FormFieldView(
            field: field,
            value: binding,
            locale: locale,
            cardType: { if case .creditCardNumber = field.type { return detectedCardType } else { return nil } }(),
            installmentPlans: field.type == .installmentPlan ? stateStore.installmentPlans : nil,
            selectedCountry: field.type == .province ? selectedCountryValue() : "",
            phoneCountryCode: field.type == .phoneNumber ? stateStore.phoneCountryCode : "",
            onChanged: {
                if case .creditCardNumber = field.type {
                    XenditComponents.activeSDK?.stateStore.cardNumber = binding.wrappedValue
                }
                if field.type == .installmentPlan {
                    let encoded = binding.wrappedValue
                    stateStore.selectedInstallmentPlan = stateStore.installmentPlans?.first(where: {
                        "\($0.terms)|\($0.interval)|\($0.code ?? "")" == encoded
                    })
                }
                onPropertiesChanged?(channelProperties)
            },
            onValidationChanged: { error in
                if let error = error {
                    fieldErrors[field.id] = error
                } else {
                    fieldErrors.removeValue(forKey: field.id)
                }
            }
        )
    }

    private func mapper(for field: Form.InputField) -> FieldPropertyMapper {
        switch field.type {
        case .creditCardExpiry:
            return CreditCardExpiryMapper()
        case .installmentPlan:
            return InstallmentPlanFieldMapper()
        default:
            return DefaultFieldMapper()
        }
    }

    /// Returns the currently selected country value for use by province fields.
    private func selectedCountryValue() -> String {
        for section in formPage.sections {
            for component in section.components {
                if case .inputField(let f) = component, f.type == .country {
                    return channelProperties[f.channelProperty.primaryKey] ?? ""
                }
                if case .row(let subComponents, _, _) = component {
                    for sub in subComponents {
                        if case .inputField(let f) = sub, f.type == .country {
                            return channelProperties[f.channelProperty.primaryKey] ?? ""
                        }
                    }
                }
            }
        }
        return ""
    }
}

private enum RenderGroup {
    case standalone(Form.Component)
    case joined([Form.Component])
}

private extension Form.VerticalAlignment {
    var verticalAlignment: VerticalAlignment {
        switch self {
        case .center:
            return .center
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
}
