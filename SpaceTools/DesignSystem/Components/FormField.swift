//
//  FormField.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var badge: Badge?

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

            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
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
