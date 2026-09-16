import PhotosUI
import SwiftUI

struct StudioView: View {
    @State private var model = StudioViewModel()

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            ZStack {
                StudioPalette.canvas.ignoresSafeArea()

                VStack(spacing: 20) {
                    photoStage
                    caption
                    controls
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .padding(.top, 8)
            }
            .navigationTitle(L10n.appName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ModePill(title: model.modeLabel, cloud: model.usesCloudAI)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if model.canStartOver {
                            Button(L10n.startOver, action: model.startOver)
                        }
                        Button {
                            model.showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel(L10n.settings)
                    }
                }
            }
            .photosPicker(
                isPresented: $model.showLibrary,
                selection: $model.pickerItem,
                matching: .images
            )
            .onChange(of: model.pickerItem) { _, item in
                Task { await model.handlePickedItem(item) }
            }
            .fullScreenCover(isPresented: $model.showCamera) {
                CameraPicker(
                    onImage: { image in
                        model.showCamera = false
                        model.acceptCameraImage(image)
                    },
                    onCancel: { model.showCamera = false }
                )
                .ignoresSafeArea()
            }
            .sheet(isPresented: $model.showShare) {
                ShareSheet(items: model.shareItems())
            }
            .sheet(isPresented: $model.showSettings) {
                SettingsView(onChange: model.refreshStudioMode)
            }
            .alert(L10n.cameraUnavailableTitle, isPresented: $model.cameraUnavailable) {
                Button(L10n.cameraUnavailableChoose) { model.showLibrary = true }
                Button(L10n.ok, role: .cancel) {}
            } message: {
                Text(L10n.cameraUnavailableMessage)
            }
            .overlay(alignment: .top) {
                if let toast = model.toast {
                    ToastBanner(text: toast)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.snappy, value: model.toast)
        }
        .tint(StudioPalette.accent)
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private var photoStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(StudioPalette.card)
                .shadow(color: .black.opacity(0.08), radius: 24, y: 10)

            switch model.phase {
            case .empty:
                EmptyPhotoCard()
            case .ready(let image):
                PhotoCard(image: image)
            case .generating(let image, let status):
                PhotoCard(image: image)
                    .overlay { GeneratingOverlay(status: status) }
            case .result(let original, let headshot):
                BeforeAfterSlider(before: original, after: headshot)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            case .failed(let image, let message):
                PhotoCard(image: image)
                    .overlay(alignment: .bottom) {
                        ErrorBanner(message: message, retry: model.retry)
                            .padding(12)
                    }
            }
        }
        .aspectRatio(4 / 5, contentMode: .fit)
        .frame(maxWidth: 420)
        .frame(maxHeight: .infinity)
    }

    private var caption: some View {
        Text(captionText)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 360)
    }

    private var captionText: String {
        switch model.phase {
        case .empty:
            return L10n.captionEmpty
        case .ready:
            return L10n.captionReady
        case .generating:
            return model.usesCloudAI ? L10n.captionGeneratingCloud : L10n.captionGeneratingDevice
        case .result:
            return L10n.captionResult
        case .failed:
            return L10n.captionFailed
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SourceButton(
                    title: L10n.camera,
                    systemImage: "camera.fill",
                    enabled: !model.phase.isGenerating
                ) {
                    model.requestCamera()
                }

                SourceButton(
                    title: L10n.library,
                    systemImage: "photo.on.rectangle",
                    enabled: !model.phase.isGenerating
                ) {
                    model.showLibrary = true
                }
            }

            switch model.phase {
            case .empty, .ready, .generating, .failed:
                Button(action: model.createHeadshot) {
                    Label(L10n.create, systemImage: "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 14))
                .disabled(!model.canCreate)
            case .result:
                HStack(spacing: 12) {
                    Button {
                        model.showShare = true
                    } label: {
                        Label(L10n.share, systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 14))

                    Button {
                        Task { await model.saveToPhotos() }
                    } label: {
                        if model.isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        } else {
                            Label(L10n.save, systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 14))
                    .disabled(model.isSaving)
                }
                .font(.headline)
            }
        }
    }
}

private struct ModePill: View {
    let title: String
    let cloud: Bool

    var body: some View {
        Label(title, systemImage: cloud ? "cloud" : "iphone")
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(StudioPalette.card, in: Capsule())
            .foregroundStyle(.secondary)
            .accessibilityLabel(cloud ? L10n.modeCloudA11y : L10n.modeDeviceA11y)
    }
}

private struct EmptyPhotoCard: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(StudioPalette.accent)
            Text(L10n.emptyTitle)
                .font(.headline)
            Text(L10n.emptyBody)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PhotoCard: View {
    let image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .accessibilityLabel(L10n.photoA11y)
    }
}

private struct GeneratingOverlay: View {
    let status: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)
                    .tint(StudioPalette.accent)
                Text(status)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(L10n.generatingA11y), \(status)")
    }
}

private struct ErrorBanner: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Button(L10n.retry, action: retry)
                .font(.subheadline.weight(.semibold))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ToastBanner: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }
}

private struct SourceButton: View {
    let title: String
    let systemImage: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 14))
        .disabled(!enabled)
    }
}

#Preview {
    StudioView()
}
