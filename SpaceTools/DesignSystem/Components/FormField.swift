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
    var badge: Badge?
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
                    Text(badge.text)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(badge.color.opacity(0.15))
                        .foregroundColor(badge.color)
                        .cornerRadius(4)
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

// MARK: - Badge

extension FormField {
    enum Badge {
        case production
        case dev
        case test

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
}

// MARK: - Convenience Initializer

extension FormField where FocusValue == Never {
    init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        badge: Badge? = nil
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
