import SwiftUI
import UIKit

struct BeforeAfterSlider: View {
    let before: UIImage
    let after: UIImage
    @State private var split = 0.54

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let x = width * split

            ZStack(alignment: .leading) {
                image(before)
                    .frame(width: width, height: height)
                    .overlay(alignment: .bottomTrailing) {
                        badge("Original")
                            .padding(12)
                    }

                image(after)
                    .frame(width: width, height: height)
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: max(x, 0))
                    }
                    .overlay(alignment: .bottomLeading) {
                        badge("Headshot")
                            .padding(12)
                    }

                handle
                    .position(x: x, y: height / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        split = min(max(value.location.x / width, 0.08), 0.92)
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Before and after comparison")
            .accessibilityValue("Showing \(Int(split * 100)) percent headshot")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    split = min(split + 0.08, 0.92)
                case .decrement:
                    split = max(split - 0.08, 0.08)
                @unknown default:
                    break
                }
            }
        }
    }

    private func image(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .clipped()
    }

    private var handle: some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .frame(width: 2)
                .shadow(color: .black.opacity(0.25), radius: 2)
            Circle()
                .fill(.white)
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 1)
                .overlay {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(StudioPalette.ink)
                }
        }
        .allowsHitTesting(false)
    }

    private func badge(_ title: String) -> some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
