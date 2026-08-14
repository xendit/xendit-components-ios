//
//  BottomSheetPickerFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

/// A reusable field that presents a bottom sheet list for picking a single option.
/// Set `searchEnabled: true` when the list is long enough to warrant filtering.
struct BottomSheetPickerFieldView: View {
    let label: String
    let placeholder: String
    let options: [PickerOption]
    @Binding var value: String
    var isDisabled: Bool = false
    var searchEnabled: Bool = false
    var showIconDivider: Bool = false
    var iconSize: CGSize = CGSize(width: 16, height: 16)
    var iconClipShape: IconClipShape = .circle
    var onChanged: (() -> Void)?

    enum IconClipShape: Shape {
        case circle
        case roundedRectangle(cornerRadius: CGFloat)
        case rectangle

        func path(in rect: CGRect) -> Path {
            switch self {
            case .circle:
                return Circle().path(in: rect)
            case .roundedRectangle(let cornerRadius):
                return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
            case .rectangle:
                return Rectangle().path(in: rect)
            }
        }
    }

    @State private var isPresented: Bool = false

    // MARK: - Option model

    struct PickerOption: Identifiable {
        var id: String { value }
        let label: String
        let subtitle: String?
        let value: String
        var iconUrl: String? = nil
        var isDisabled: Bool = false
    }

    // MARK: - Body

    private var selectedOption: PickerOption? {
        guard !value.isEmpty else { return nil }
        return options.first(where: { $0.value == value })
    }
    
    var body: some View {
        XenditLabeledField(label: label) {
            Button(action: { if !isDisabled { isPresented = true } }) {
                HStack(spacing: Spacing.s2) {
                    if let iconUrl = selectedOption?.iconUrl {
                        RemoteImage(url: URL(string: iconUrl))
                            .frame(width: iconSize.width, height: iconSize.height)
                            .clipShape(iconClipShape)
                        if showIconDivider {
                            Rectangle()
                                .fill(XenditComponents.appearance.resolvedBorder)
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                                .padding(.vertical, Spacing.s2)
                        }
                    }
                    Text(selectedOption?.label ?? placeholder)
                        .font(.labelLgRegular)
                        .foregroundColor(value.isEmpty
                                         ? XenditComponents.appearance.resolvedTextPlaceholder
                                         : XenditComponents.appearance.resolvedText)
                    
                    Spacer()
                    if !isDisabled {
                        Image(systemName: "chevron.down")
                            .font(.labelLgRegular)
                            .foregroundColor(.Text.default)
                    }
                }
                .contentShape(Rectangle())
                .padding(.horizontal, Spacing.s3)
                .frame(height: 44)
                .xenditFieldBorder()
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $isPresented) {
            XenditPickerSheet(
                title: label,
                options: options,
                value: $value,
                searchEnabled: searchEnabled,
                onSelected: { selected in
                    value = selected
                    onChanged?()
                }
            )
            .modifier(SheetDetentsModifier())
        }
    }

}

// MARK: - Reusable Picker Sheet

/// Standalone bottom sheet picker — can be used independently of BottomSheetPickerFieldView.
struct XenditPickerSheet: View {
    let title: String
    let options: [BottomSheetPickerFieldView.PickerOption]
    @Binding var value: String
    var searchEnabled: Bool = false
    var searchPlaceholder: String = "Search"
    /// Custom per-item filter predicate. Receives the search query and option; return true to include.
    /// Defaults to case-insensitive label match when nil.
    var searchFilter: ((String, BottomSheetPickerFieldView.PickerOption) -> Bool)? = nil
    let onSelected: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    /// Lags 250 ms behind searchText so filtering doesn't run on every keystroke.
    @State private var debouncedQuery = ""
    @State private var searchTask: Task<Void, Never>? = nil

    private var filteredOptions: [BottomSheetPickerFieldView.PickerOption] {
        let query = debouncedQuery.trimmingCharacters(in: .whitespaces)
        guard searchEnabled, !query.isEmpty else { return options }
        if let filter = searchFilter {
            return options.filter { filter(query, $0) }
        }
        return options.filter { $0.label.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader(title: title)

            Divider()

            if searchEnabled {
                searchBar
                    .onChange(of: searchText) { newValue in
                        searchTask?.cancel()
                        // Clear immediately so the full list snaps back without delay.
                        if newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                            debouncedQuery = ""
                            return
                        }
                        searchTask = Task { @MainActor in
                            do { try await Task.sleep(nanoseconds: 250_000_000) } catch { return }
                            debouncedQuery = newValue
                        }
                    }
                Divider()
            }

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredOptions) { option in
                        optionRow(option)
                        Divider()
                            .padding(.leading, option.iconUrl != nil ? 56 : 16)
                    }
                }
            }
        }
        .background(XenditComponents.appearance.resolvedBackground)
        .onDisappear { searchTask?.cancel() }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(searchPlaceholder, text: $searchText)
                .font(InterFont.bodyMd)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(Spacing.s3)
        .background(RoundedRectangle(cornerRadius: CornerRadius.md).fill(XenditComponents.appearance.resolvedDisabled))
        .padding(.horizontal, Spacing.s4)
        .padding(.vertical, Spacing.s2)
    }

    private func optionRow(_ option: BottomSheetPickerFieldView.PickerOption) -> some View {
        let isSelected = option.value == value
        return Button {
            guard !option.isDisabled else { return }
            onSelected(option.value)
            dismiss()
        } label: {
            HStack(spacing: Spacing.s3) {
                if let iconUrl = option.iconUrl {
                    RemoteImage(url: URL(string: iconUrl))
                        .frame(width: 24, height: 24)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .font(.labelLgRegular)
                        .foregroundColor(.Text.default)
                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .font(.labelSmRegular)
                            .foregroundColor(.Text.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
                if isSelected && !option.isDisabled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(XenditComponents.appearance.resolvedPrimary)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, Spacing.s4)
            .padding(.vertical, Spacing.s3)
        }
        .buttonStyle(.plain)
        .disabled(option.isDisabled)
    }
}

// MARK: - Shared sheet header

@MainActor
func sheetHeader(title: String) -> some View {
    ZStack {
        Text(title)
            .font(.headingH3)
            .foregroundColor(.Text.default)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
        HStack {
            Spacer()
            DismissButton()
        }
    }
    .padding(.horizontal, Spacing.s4)
    .padding(.top, Spacing.s4)
    .padding(.bottom, Spacing.s3)
}

private struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .padding(Spacing.s2)
        }
    }
}
