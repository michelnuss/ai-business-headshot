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
            .navigationTitle("Headshot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ModePill(title: model.modeLabel, cloud: model.usesCloudAI)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if model.canStartOver {
                        Button("Start over", action: model.startOver)
                    }
                }
            }
            .photosPicker(
                isPresented: $model.showLibrary,
                selection: $model.pickerItem,
                matching: .images,
                photoLibrary: .shared()
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
            .alert("Camera isn’t available", isPresented: $model.cameraUnavailable) {
                Button("Choose a photo") { model.showLibrary = true }
                Button("OK", role: .cancel) {}
            } message: {
                Text("This \(simulatorWord) doesn’t have a camera. Pick a portrait from the library instead.")
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

    private var simulatorWord: String {
        #if targetEnvironment(simulator)
        "simulator"
        #else
        "device"
        #endif
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
            return "Lighting, background, and attire only — facial structure stays unchanged."
        case .ready:
            return "A clear, well-lit face looking toward the camera works best."
        case .generating:
            return model.usesCloudAI
                ? "Sending a high-fidelity edit so your face stays yours."
                : "On-device studio: background, crop, and light. Paste an API key for attire."
        case .result:
            return "Drag the handle to compare. Save or share when it looks right."
        case .failed:
            return "Nothing was overwritten. You can retry or pick another photo."
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SourceButton(
                    title: "Camera",
                    systemImage: "camera.fill",
                    enabled: !model.phase.isGenerating
                ) {
                    model.requestCamera()
                }

                SourceButton(
                    title: "Library",
                    systemImage: "photo.on.rectangle",
                    enabled: !model.phase.isGenerating
                ) {
                    model.showLibrary = true
                }
            }

            switch model.phase {
            case .empty, .ready, .generating, .failed:
                Button(action: model.createHeadshot) {
                    Label("Create headshot", systemImage: "sparkles")
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
                        Label("Share", systemImage: "square.and.arrow.up")
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
                            Label("Save", systemImage: "square.and.arrow.down")
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
            .accessibilityLabel(cloud ? "Using OpenAI studio" : "Using on-device studio")
    }
}

private struct EmptyPhotoCard: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(StudioPalette.accent)
            Text("Take a photo or choose one")
                .font(.headline)
            Text("Use a snapshot of yourself. The studio keeps you recognizable.")
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
            .accessibilityLabel("Selected portrait")
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
        .accessibilityLabel("Creating headshot, \(status)")
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
            Button("Try again", action: retry)
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
