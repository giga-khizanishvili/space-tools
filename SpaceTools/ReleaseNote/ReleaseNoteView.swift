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

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                settingsSection
                generalInfoSection
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
        .onSubmit(submit)
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
                FormField(label: "Version", placeholder: "e.g., 2.35.0", text: $version)
                FormField(label: "Status", placeholder: "e.g., Waiting for Review", text: $status)
            }
        }
    }

    var buildNumbersSection: some View {
        CardView(title: "Build Numbers", icon: "number.circle") {
            VStack(spacing: 16) {
                ForEach(visibleBuildSources, id: \.self) { source in
                    FormField(
                        label: source.name,
                        placeholder: "Build number",
                        text: buildNumberBinding(for: source),
                        badge: source.badge
                    )
                }
            }
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

    var badge: BuildBadge? {
        switch self {
        case .production: .production
        case .devAdhoc, .devTestFlight: .dev
        case .testAdhoc, .testTestFlight: .test
        }
    }
}

// MARK: - Build Badge

private enum BuildBadge {
    case production
    case dev
    case test

    var text: String {
        switch self {
        case .production: "PROD"
        case .dev: "DEV"
        case .test: "TEST"
        }
    }

    var color: Color {
        switch self {
        case .production: .green
        case .dev: .orange
        case .test: .blue
        }
    }
}

// MARK: - Card View

private struct CardView<Content: View>: View {
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

    private var headerView: some View {
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

// MARK: - Form Field

private struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var badge: BuildBadge?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let badge {
                    Text(badge.text)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(badge.color.opacity(0.15))
                        .foregroundColor(badge.color)
                        .cornerRadius(4)
                }
            }

            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
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
