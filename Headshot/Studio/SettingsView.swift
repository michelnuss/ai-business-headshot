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
                    SecureField("sk-…", text: $draft)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    Button("Save key") {
                        APIKeyStore.save(draft)
                        hasStoredKey = APIKeyStore.load() != nil
                        draft = ""
                        onChange()
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if hasStoredKey {
                        Button("Remove key", role: .destructive) {
                            APIKeyStore.clear()
                            hasStoredKey = false
                            draft = ""
                            onChange()
                        }
                    }
                } header: {
                    Text("OpenAI API key")
                } footer: {
                    Text(footerText)
                }

                Section("This build") {
                    LabeledContent("Bundle ID", value: Bundle.main.bundleIdentifier ?? "—")
                    LabeledContent("Version", value: versionString)
                    LabeledContent("Studio", value: AppConfig.usesCloudAI ? "OpenAI" : "On-device")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                hasStoredKey = APIKeyStore.load() != nil
            }
        }
    }

    private var footerText: String {
        if !AppConfig.openAIAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "A compile-time key is set in AppConfig.swift and takes priority. Leave that string empty for App Store builds and paste a key here instead. The key stays in the Keychain on this device."
        }
        return "Leave AppConfig.swift empty for App Store / TestFlight. Paste a key here to enable cloud studio. It is stored in the Keychain on this iPhone only — never commit a key. Photos are sent to OpenAI only when a key is present."
    }

    private var versionString: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(short) (\(build))"
    }
}
