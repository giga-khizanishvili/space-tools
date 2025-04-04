//
//  View+Toast.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}
