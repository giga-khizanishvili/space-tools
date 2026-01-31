//
//  ToastView.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct ToastView: View {
    let style: Toast.Style
    let message: String
    let onCancelTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: style.iconFileName)
                .font(.title3)
                .foregroundColor(style.themeColor)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer(minLength: 10)

            Button(action: onCancelTap) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.windowBackgroundColor))
                .shadow(color: style.themeColor.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style.themeColor.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 20) {
        ToastView(style: .success, message: "Operation completed!", onCancelTap: {})
        ToastView(style: .error, message: "Something went wrong", onCancelTap: {})
        ToastView(style: .warning, message: "Please check your input", onCancelTap: {})
        ToastView(style: .info, message: "New update available", onCancelTap: {})
    }
    .padding()
    .frame(width: 400)
}
