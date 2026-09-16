import SwiftUI

struct SettingsView: View {
    var onChange: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var hasStoredKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField(L10n.Settings.placeholder, text: $draft)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    Button(L10n.Settings.saveKey) {
                        APIKeyStore.save(draft)
                        hasStoredKey = APIKeyStore.load() != nil
                        draft = ""
                        onChange()
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if hasStoredKey {
                        Button(L10n.Settings.removeKey, role: .destructive) {
                            APIKeyStore.clear()
                            hasStoredKey = false
                            draft = ""
                            onChange()
                        }
                    }
                } header: {
                    Text(L10n.Settings.keyHeader)
                } footer: {
                    Text(footerText)
                }

                Section(L10n.Settings.thisBuild) {
                    LabeledContent(L10n.Settings.bundle, value: Bundle.main.bundleIdentifier ?? "—")
                    LabeledContent(L10n.Settings.version, value: versionString)
                    LabeledContent(
                        L10n.Settings.studio,
                        value: AppConfig.usesCloudAI ? L10n.Settings.studioCloud : L10n.Settings.studioDevice
                    )
                }
            }
            .navigationTitle(L10n.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.done) { dismiss() }
                }
            }
            .onAppear {
                hasStoredKey = APIKeyStore.load() != nil
            }
        }
    }

    private var footerText: String {
        if !AppConfig.openAIAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return L10n.Settings.footerCompileTime
        }
        return L10n.Settings.footerRuntime
    }

    private var versionString: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(short) (\(build))"
    }
}
