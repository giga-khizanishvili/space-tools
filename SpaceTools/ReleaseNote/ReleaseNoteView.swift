//
//  ReleaseNoteView.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct ReleaseNoteView: View {
    @AppStorage("spaceTools.version") private var version = "2.35.0"
    @AppStorage("spaceTools.showDevBuilds") private var showDevBuilds = true

    @State private var status = "Waiting for Review"
    @State private var buildNumbers: [BuildSource: String] = Dictionary(
        uniqueKeysWithValues: BuildSource.allCases.map { ($0, "") }
    )
    @State private var toast: Toast?
    @State private var showPreview = false

    @FocusState private var focusedField: FocusField?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                generalInfoSection
                settingsSection
                buildNumbersSection
                previewSection
                generateButton
            }
            .padding(24)
            .animation(.easeInOut(duration: 0.2), value: showDevBuilds)
        }
        .background(Color(.windowBackgroundColor).opacity(0.5))
        .toast($toast)
        .navigationTitle("Release Note Factory")
        .toolbar { toolbarContent }
    }
}

// MARK: - Focus Field

private extension ReleaseNoteView {
    enum FocusField: Hashable {
        case version
        case status
        case buildSource(BuildSource)
    }
}

// MARK: - Subviews

private extension ReleaseNoteView {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button(action: resetBuildNumbers) {
                Label("Clear Build Numbers", systemImage: "arrow.counterclockwise")
            }
            .help("Clear all build numbers")
        }
    }

    var settingsSection: some View {
        HStack {
            Spacer()
            Toggle("Include Dev Builds", isOn: $showDevBuilds)
                .toggleStyle(.switch)
                .tint(.accentColor)
        }
    }

    var generalInfoSection: some View {
        CardView(title: "General Info", icon: "info.circle") {
            VStack(spacing: 16) {
                FormField(
                    label: "Version",
                    placeholder: "e.g., 2.35.0",
                    text: $version,
                    focusedField: $focusedField,
                    fieldValue: .version,
                    onSubmit: { focusedField = .status }
                )
                FormField(
                    label: "Status",
                    placeholder: "e.g., Waiting for Review",
                    text: $status,
                    focusedField: $focusedField,
                    fieldValue: .status,
                    onSubmit: { focusedField = .buildSource(.production) }
                )
            }
        }
    }

    var buildNumbersSection: some View {
        CardView(title: "Build Numbers", icon: "number.circle") {
            VStack(spacing: 16) {
                productionBuildField
                otherBuildFields
            }
        }
    }

    var productionBuildField: some View {
        HStack(alignment: .bottom, spacing: 12) {
            FormField(
                label: BuildSource.production.name,
                placeholder: "Build number",
                text: buildNumberBinding(for: .production),
                badge: BuildSource.production.badge,
                focusedField: $focusedField,
                fieldValue: .buildSource(.production),
                onSubmit: { moveFocusAfter(.production) }
            )

            Button(action: fillBuildNumbersAutomatically) {
                Label("Auto-fill", systemImage: "wand.and.stars")
            }
            .buttonStyle(.bordered)
            .help("Fill other build numbers automatically (+1, +2, ...)")
            .disabled(Int(buildNumbers[.production] ?? "") == nil)
        }
    }

    @ViewBuilder
    var otherBuildFields: some View {
        ForEach(visibleBuildSources.filter { $0 != .production }, id: \.self) { source in
            FormField(
                label: source.name,
                placeholder: "Build number",
                text: buildNumberBinding(for: source),
                badge: source.badge,
                focusedField: $focusedField,
                fieldValue: .buildSource(source),
                onSubmit: { moveFocusAfter(source) }
            )
        }
    }

    var previewSection: some View {
        CardView(
            title: "Preview",
            icon: "doc.text",
            isCollapsible: true,
            isExpanded: $showPreview
        ) {
            if showPreview {
                Text(releaseNote)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showPreview.toggle()
            }
        }
    }

    var generateButton: some View {
        Button(action: submit) {
            HStack(spacing: 8) {
                Image(systemName: "doc.on.clipboard")
                Text("Generate & Copy to Clipboard")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .keyboardShortcut(.return, modifiers: .command)
        .disabled(!isFormValid)
    }
}

// MARK: - Computed Properties

private extension ReleaseNoteView {
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

private extension ReleaseNoteView {
    func submit() {
        guard isFormValid else { return }

        focusedField = nil
        copyToClipboard(releaseNote)

        toast = Toast(
            style: .success,
            message: "Release note copied to clipboard!"
        )
    }

    func resetBuildNumbers() {
        withAnimation {
            for source in BuildSource.allCases {
                buildNumbers[source] = ""
            }
        }
    }

    func fillBuildNumbersAutomatically() {
        guard let baseBuildNumber = Int(buildNumbers[.production] ?? "") else { return }

        let otherSources: [BuildSource] = [.devAdhoc, .devTestFlight, .testAdhoc, .testTestFlight]

        withAnimation {
            for (index, source) in otherSources.enumerated() {
                buildNumbers[source] = String(baseBuildNumber + index + 1)
            }
        }
    }

    func moveFocusAfter(_ source: BuildSource) {
        let sources = visibleBuildSources
        guard let currentIndex = sources.firstIndex(of: source) else {
            submit()
            return
        }

        let nextIndex = currentIndex + 1
        if nextIndex < sources.count {
            focusedField = .buildSource(sources[nextIndex])
        } else {
            submit()
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

// MARK: - Helpers

private extension ReleaseNoteView {
    func buildNumberBinding(for source: BuildSource) -> Binding<String> {
        Binding(
            get: { buildNumbers[source] ?? "" },
            set: { buildNumbers[source] = $0 }
        )
    }

    func makeBuildString(_ buildNumber: String) -> String {
        "Build - v\(version)(\(buildNumber))"
    }
}

// MARK: - Build Source

private enum BuildSource: CaseIterable, Hashable {
    case production
    case devAdhoc
    case devTestFlight
    case testAdhoc
    case testTestFlight

    static var allCases: [BuildSource] {
        [.production, .devAdhoc, .devTestFlight, .testAdhoc, .testTestFlight]
    }

    static var withoutDev: [BuildSource] {
        [.production, .testAdhoc, .testTestFlight]
    }

    static var devCases: [BuildSource] {
        [.devAdhoc, .devTestFlight]
    }

    static var testCases: [BuildSource] {
        [.testAdhoc, .testTestFlight]
    }

    var name: String {
        switch self {
        case .production: "Production"
        case .devAdhoc: "Dev Adhoc"
        case .devTestFlight: "Dev TestFlight"
        case .testAdhoc: "Test Adhoc"
        case .testTestFlight: "Test TestFlight"
        }
    }

    var badge: FormField<ReleaseNoteView.FocusField>.Badge? {
        switch self {
        case .production: .production
        case .devAdhoc, .devTestFlight: .dev
        case .testAdhoc, .testTestFlight: .test
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReleaseNoteView()
    }
    .frame(width: 500, height: 700)
}
