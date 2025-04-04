//
//  ToastModifier.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct ToastModifier: ViewModifier {

    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: 32)
                }
                    .animation(.spring(), value: toast)
            )
            .onChange(of: toast) { oldValue, newValue in
                showToast()
            }
    }
}

// MARK: - Private
private extension ToastModifier {
    @ViewBuilder
    func mainToastView() -> some View {
        if let toast {
            VStack {
                ToastView(
                    style: toast.style,
                    message: toast.message,
                    onCancelTap: dismissToast
                )
                Spacer()
            }
        }
    }

    func showToast() {
        guard let toast else { return }

#if os(iOS) || os(visionOS)
        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
#endif

        if toast.duration > 0 {
            workItem?.cancel()

            let task = DispatchWorkItem {
                dismissToast()
            }

            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }

    func dismissToast() {
        withAnimation {
            toast = nil
        }

        workItem?.cancel()
        workItem = nil
    }
}
