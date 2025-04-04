//
//  ReleaseNoteView.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct ReleaseNoteView: View {

    @State private var version = "2.35.0"

    @State private var status = "Waiting for Review"

    @State private var buildNumbers: [BuildSource: String] = Dictionary(
        uniqueKeysWithValues: BuildSource.allCases.map { buildSource in
            (key: buildSource, value: "")
        }
    )

    @State private var toast: Toast?

    // MARK: - Body
    var body: some View {
        Form {
            Section(header: makeSectionHeader("General Info")) {
                TextField("Version", text: $version)
                TextField("Status", text: $status)
            }

            spacer

            Section(header: makeSectionHeader("Build Numbers")) {
                ForEach(BuildSource.allCases, id: \.name) { buildSource in
                    TextField(
                        buildSource.name,
                        text: .init(
                            get: { self.buildNumbers[buildSource]! },
                            set: { self.buildNumbers[buildSource] = $0 }
                        )
                    )
                }
            }

            spacer

            Button(
                action: submit,
                label: {
                    Text("Generate Release Note and Copy")
                        .buttonStyle(.bordered)
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity)
                }
            )
        }
        .padding()
        .toast($toast)
        .navigationTitle("Release Note Factory")
        .onSubmit(submit)
    }
}

// MARK: - Private
private extension ReleaseNoteView {
    var tag: String {
        "UZ-V-\(version)"
    }

    var tagURL: URL {
        URL(string: "https://github.com/SpaceBank/iOS-Space/releases/tag/\(tag)")!
    }

    var releaseNote: String {
        """
        Tag - [\(tag)](\(tagURL))
        \(makeBuildString(buildNumbers[.production]!))
        
        *Status - \(status)*
        
        \(allBuildInformation)
        """
    }

    var allBuildInformation: String {
        BuildSource.allCases
            .filter { $0 != .production }
            .map { source in
                """
                *\(source.name)*:
                Build - v\(version)(\(buildNumbers[source]!))
                
                
                """
            }
            .joined()
    }

    func makeBuildString(_ buildNumber: String) -> String {
        "Build - v\(version)(\(buildNumber))"
    }

    func copyToClipboard(_ text: String) {
#if os(iOS) || os(visionOS)
        UIPasteboard.general.string = text
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
#endif
    }

    func submit() {
        copyToClipboard(releaseNote)

        toast = .init(
            style: .success,
            message: "Copied to clipboard!"
        )
    }

    var spacer: some View {
        Spacer()
            .frame(height: 24)
    }

    func makeSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
    }
}

// MARK: - Build Source
private enum BuildSource: CaseIterable {
    case production
    case devAdhoc
    case devTestFlight
    case testAdhoc
    case testTestFlight


    static var allCases: [BuildSource] {
        [.production, .devAdhoc, .devTestFlight, .testAdhoc, .testTestFlight]
    }

    var name: String {
        switch self {
        case .production: 
            "Production"
        case .devAdhoc: 
            "Dev Adhoc"
        case .devTestFlight: 
            "Dev TestFlight"
        case .testAdhoc:
            "Test Adhoc"
        case .testTestFlight:
            "Test TestFlight"
        }
    }
}

#Preview {
    ReleaseNoteView()
}
