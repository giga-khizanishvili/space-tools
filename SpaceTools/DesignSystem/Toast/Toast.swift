//
//  Toast.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

// Source: https://ondrej-kvasnovsky.medium.com/how-to-build-a-simple-toast-message-view-in-swiftui-b2e982340bd

import SwiftUI

// MARK: - Toast
struct Toast: Equatable {
    let style: Style
    let message: String
    var duration: Double = 3
}

// MARK: - Style
extension Toast {
    enum Style {
        case error
        case warning
        case success
        case info

        var themeColor: Color {
            switch self {
            case .error: .red
            case .warning: .orange
            case .info: .blue
            case .success: .green
            }
        }

        var iconFileName: String {
            switch self {
            case .info: "info.circle.fill"
            case .warning: "exclamationmark.triangle.fill"
            case .success: "checkmark.circle.fill"
            case .error: "xmark.circle.fill"
            }
        }
    }
}
