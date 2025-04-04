//
//  ToastView.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct ToastView: View {

    // MARK: - Properties
    let style: Toast.Style
    let message: String
    let onCancelTap: (() -> Void)

    // MARK: - Body
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: style.iconFileName)
                .foregroundColor(style.themeColor)

            Text(message)
                .font(.caption)

            Spacer(minLength: 10)

            Button(
                action: onCancelTap,
                label: {
                    Image(systemName: "xmark")
                        .foregroundColor(style.themeColor)
                }
            )
        }
        .padding()
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .opacity(0.6)
        )
        .padding(.horizontal, 16)
    }
}
