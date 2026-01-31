//
//  CardView.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct CardView<Content: View>: View {
    let title: String
    let icon: String
    var isCollapsible: Bool = false
    var isExpanded: Binding<Bool>?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            if !isCollapsible || (isExpanded?.wrappedValue ?? true) {
                content()
            }
        }
        .padding(20)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Subviews

private extension CardView {
    var headerView: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            if isCollapsible {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded?.wrappedValue.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded?.wrappedValue ?? false ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
