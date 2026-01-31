//
//  FormField.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct FormField<FocusValue: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var badge: BadgeType?
    var focusedField: FocusState<FocusValue?>.Binding?
    var fieldValue: FocusValue?
    var onSubmit: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let badge {
                    BadgeView(type: badge)
                }
            }

            textField
        }
    }
}

// MARK: - Subviews

private extension FormField {
    @ViewBuilder
    var textField: some View {
        if let focusedField, let fieldValue {
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .focused(focusedField, equals: fieldValue)
                .onSubmit { onSubmit?() }
        } else {
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .onSubmit { onSubmit?() }
        }
    }
}

// MARK: - Badge View

private struct BadgeView: View {
    let type: BadgeType

    var body: some View {
        Text(type.text)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(type.color.opacity(0.15))
            .foregroundColor(type.color)
            .cornerRadius(4)
    }
}

// MARK: - Badge Type Extension

extension BadgeType {
    var text: String {
        switch self {
        case .production: "PROD"
        case .dev: "DEV"
        case .test: "TEST"
        }
    }

    var color: Color {
        switch self {
        case .production: .green
        case .dev: .orange
        case .test: .blue
        }
    }
}

// MARK: - Convenience Initializer

extension FormField where FocusValue == Never {
    init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        badge: BadgeType? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.badge = badge
        self.focusedField = nil
        self.fieldValue = nil
        self.onSubmit = nil
    }
}
