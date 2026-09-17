import PhotosUI
import SwiftUI

struct StudioView: View {
    @State private var model = StudioViewModel()

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            ZStack {
                StudioPalette.canvas.ignoresSafeArea()

                VStack(spacing: 12) {
                    tagline
                    photoStage
                    trustStrip
                    caption
                    controls
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .padding(.top, 4)
            }
            .navigationTitle(L10n.appName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(StudioPalette.canvas, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        if model.canStartOver {
                            Button(action: model.startOver) {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .accessibilityLabel(L10n.startOver)
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

    private var tagline: some View {
        Text(L10n.tagline)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var photoStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: StudioPalette.stageRadius, style: .continuous)
                .fill(StudioPalette.card)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 3)

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
                    .clipShape(RoundedRectangle(cornerRadius: StudioPalette.stageRadius, style: .continuous))
            case .failed(let image, let message):
                PhotoCard(image: image)
                    .overlay(alignment: .bottom) {
                        ErrorBanner(message: message, retry: model.retry)
                            .padding(12)
                    }
            }
        }
        .overlay {
            if case .empty = model.phase {
                RoundedRectangle(cornerRadius: StudioPalette.stageRadius, style: .continuous)
                    .strokeBorder(StudioPalette.chipStroke, lineWidth: 1)
            }
        }
        .aspectRatio(4 / 5, contentMode: .fit)
        .frame(maxWidth: 420)
        .frame(maxHeight: .infinity)
    }

    private var trustStrip: some View {
        TrustStrip(cloud: model.usesCloudAI, modeTitle: model.modeLabel)
    }

    @ViewBuilder
    private var caption: some View {
        if showsCaption {
            Text(captionText)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
    }

    private var showsCaption: Bool {
        switch model.phase {
        case .empty:
            return false
        default:
            return true
        }
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
        VStack(spacing: 10) {
            HStack(spacing: 10) {
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
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 12))
                .disabled(!model.canCreate)
            case .result:
                HStack(spacing: 10) {
                    Button {
                        model.showShare = true
                    } label: {
                        Label(L10n.share, systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 12))

                    Button {
                        Task { await model.saveToPhotos() }
                    } label: {
                        if model.isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        } else {
                            Label(L10n.save, systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 12))
                    .disabled(model.isSaving)
                }
                .font(.headline)
            }
        }
    }
}

private struct TrustStrip: View {
    let cloud: Bool
    let modeTitle: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: cloud ? "cloud" : "iphone")
            Text(modeTitle)
            Text("·")
                .accessibilityHidden(true)
            Text(cloud ? L10n.trustIdentity : L10n.trustNoUpload)
                .lineLimit(1)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(StudioPalette.chipFill, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        if cloud {
            return "\(L10n.modeCloudA11y). \(L10n.trustIdentity)"
        }
        return "\(L10n.modeDeviceA11y). \(L10n.trustNoUpload)"
    }
}

private struct EmptyPhotoCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(StudioPalette.accent)
            Text(L10n.emptyTitle)
                .font(.headline)
                .foregroundStyle(StudioPalette.ink)
            UseCaseChips()
            Text(L10n.emptyBody)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct UseCaseChips: View {
    var body: some View {
        HStack(spacing: 6) {
            chip(L10n.useJobs)
            chip(L10n.useVisas)
            chip(L10n.useLinkedIn)
        }
    }

    private func chip(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(StudioPalette.ink)
            .background(StudioPalette.chipFill, in: Capsule())
    }
}

private struct PhotoCard: View {
    let image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: StudioPalette.stageRadius, style: .continuous))
            .accessibilityLabel(L10n.photoA11y)
    }
}

private struct GeneratingOverlay: View {
    let status: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: StudioPalette.stageRadius, style: .continuous)
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
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .disabled(!enabled)
    }
}

#Preview {
    StudioView()
}
