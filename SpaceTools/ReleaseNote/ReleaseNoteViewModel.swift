//
//  ReleaseNoteViewModel.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

@Observable
final class ReleaseNoteViewModel {
    var version: String {
        didSet { UserDefaults.standard.set(version, forKey: "spaceTools.version") }
    }

    var showDevBuilds: Bool {
        didSet { UserDefaults.standard.set(showDevBuilds, forKey: "spaceTools.showDevBuilds") }
    }

    var status = "Waiting for Review"
    var buildNumbers: [BuildSource: String]
    var toast: Toast?
    var showPreview = false

    init() {
        self.version = UserDefaults.standard.string(forKey: "spaceTools.version") ?? "2.35.0"
        self.showDevBuilds = UserDefaults.standard.object(forKey: "spaceTools.showDevBuilds") as? Bool ?? true
        self.buildNumbers = Dictionary(uniqueKeysWithValues: BuildSource.allCases.map { ($0, "") })
    }
}

// MARK: - Computed Properties

extension ReleaseNoteViewModel {
    var visibleBuildSources: [BuildSource] {
        showDevBuilds ? BuildSource.allCases : BuildSource.withoutDev
    }

    var isFormValid: Bool {
        !version.trimmingCharacters(in: .whitespaces).isEmpty
            && !status.trimmingCharacters(in: .whitespaces).isEmpty
            && !productionBuildNumber.isEmpty
    }

    var productionBuildNumber: String {
        buildNumbers[.production]?.trimmingCharacters(in: .whitespaces) ?? ""
    }

    var canAutoFill: Bool {
        Int(buildNumbers[.production] ?? "") != nil
    }
}

// MARK: - Release Note Generation

extension ReleaseNoteViewModel {
    var tag: String {
        "UZ-V-\(version)"
    }

    var tagURL: URL {
        URL(string: "https://github.com/SpaceBank/iOS-Space/releases/tag/\(tag)")!
    }

    var releaseNote: String {
        var note = """
        Tag - [\(tag)](\(tagURL))
        \(makeBuildString(productionBuildNumber))

        *Status - \(status)*
        """

        if showDevBuilds {
            note += "\n\n" + devBuildInformation
        }

        note += "\n\n" + testBuildInformation

        return note
    }

    var devBuildInformation: String {
        makeBuildInformation(for: BuildSource.devCases)
    }

    var testBuildInformation: String {
        makeBuildInformation(for: BuildSource.testCases)
    }

    func makeBuildString(_ buildNumber: String) -> String {
        "Build - v\(version)(\(buildNumber))"
    }

    func makeBuildInformation(for sources: [BuildSource]) -> String {
        sources
            .map { source in
                let buildNumber = buildNumbers[source] ?? ""
                return """
                *\(source.name)*:
                Build - v\(version)(\(buildNumber))

                """
            }
            .joined(separator: "\n")
    }
}

// MARK: - Actions

extension ReleaseNoteViewModel {
    func submit() {
        guard isFormValid else { return }

        copyToClipboard(releaseNote)

        DispatchQueue.main.async { [weak self] in
            self?.toast = Toast(
                style: .success,
                message: "Release note copied to clipboard!"
            )
        }
    }

    func resetBuildNumbers() {
        for source in BuildSource.allCases {
            buildNumbers[source] = ""
        }
    }

    func fillBuildNumbersAutomatically() {
        guard let baseBuildNumber = Int(buildNumbers[.production] ?? "") else { return }

        let otherSources: [BuildSource] = [.devAdhoc, .devTestFlight, .testAdhoc, .testTestFlight]

        for (index, source) in otherSources.enumerated() {
            buildNumbers[source] = String(baseBuildNumber + index + 1)
        }
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
}

// MARK: - Bindings

extension ReleaseNoteViewModel {
    func buildNumberBinding(for source: BuildSource) -> Binding<String> {
        Binding(
            get: { [weak self] in self?.buildNumbers[source] ?? "" },
            set: { [weak self] in self?.buildNumbers[source] = $0 }
        )
    }
}
