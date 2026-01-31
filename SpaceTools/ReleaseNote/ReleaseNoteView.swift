//
//  ReleaseNoteView.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import SwiftUI

struct ReleaseNoteView: View {
    @State private var viewModel = ReleaseNoteViewModel()
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
            .animation(.easeInOut(duration: 0.2), value: viewModel.showDevBuilds)
        }
        .background(Color(.windowBackgroundColor).opacity(0.5))
        .toast($viewModel.toast)
        .navigationTitle("Release Note Factory")
        .toolbar { toolbarContent }
    }
}

// MARK: - Focus Field

extension ReleaseNoteView {
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
            Button(action: viewModel.resetBuildNumbers) {
                Label("Clear Build Numbers", systemImage: "arrow.counterclockwise")
            }
            .help("Clear all build numbers")
        }
    }

    var settingsSection: some View {
        HStack {
            Spacer()
            Toggle("Include Dev Builds", isOn: $viewModel.showDevBuilds)
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
                    text: $viewModel.version,
                    focusedField: $focusedField,
                    fieldValue: .version,
                    onSubmit: { focusedField = .status }
                )
                FormField(
                    label: "Status",
                    placeholder: "e.g., Waiting for Review",
                    text: $viewModel.status,
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
                text: viewModel.buildNumberBinding(for: .production),
                badge: BuildSource.production.badgeType,
                focusedField: $focusedField,
                fieldValue: .buildSource(.production),
                onSubmit: { moveFocusAfter(.production) }
            )

            Button(action: viewModel.fillBuildNumbersAutomatically) {
                Label("Auto-fill", systemImage: "wand.and.stars")
            }
            .buttonStyle(.bordered)
            .help("Fill other build numbers automatically (+1, +2, ...)")
            .disabled(!viewModel.canAutoFill)
        }
    }

    @ViewBuilder
    var otherBuildFields: some View {
        ForEach(viewModel.visibleBuildSources.filter { $0 != .production }, id: \.self) { source in
            FormField(
                label: source.name,
                placeholder: "Build number",
                text: viewModel.buildNumberBinding(for: source),
                badge: source.badgeType,
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
            isExpanded: $viewModel.showPreview
        ) {
            if viewModel.showPreview {
                Text(viewModel.releaseNote)
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
                viewModel.showPreview.toggle()
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
        .disabled(!viewModel.isFormValid)
    }
}

// MARK: - Actions

private extension ReleaseNoteView {
    func submit() {
        focusedField = nil
        viewModel.submit()
    }

    func moveFocusAfter(_ source: BuildSource) {
        let sources = viewModel.visibleBuildSources
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
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReleaseNoteView()
    }
    .frame(width: 500, height: 700)
}
