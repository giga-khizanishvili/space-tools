//
//  SpaceToolsApp.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

@main
struct SpaceToolsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ReleaseNoteView()
            }
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .defaultSize(width: 520, height: 720)
        #endif
    }
}
