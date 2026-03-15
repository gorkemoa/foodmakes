import SwiftUI

// MARK: - AsyncCachedImage
/// A drop-in async image loader with shimmer placeholder + fade-in.
struct AsyncMealImage: View {
    let url: URL?
    let contentMode: ContentMode

    init(url: URL?, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }

    var body: some View {
        GeometryReader { geo in
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ShimmerView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .transition(.opacity.animation(.easeIn(duration: 0.3)))
                    case .failure:
                        MealImagePlaceholder()
                    @unknown default:
                        ShimmerView()
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            } else {
                MealImagePlaceholder()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Shimmer Placeholder
struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemGray5),
                            Color(.systemGray4).opacity(0.5),
                            Color(.systemGray5)
                        ],
                        startPoint: UnitPoint(x: phase, y: 0),
                        endPoint: UnitPoint(x: phase + 1, y: 0)
                    )
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear {
                    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        }
    }
}

// MARK: - Meal Image Placeholder
struct MealImagePlaceholder: View {
    var body: some View {
        ZStack {
            Color(.systemGray6)
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.secondary)
                Text("No Image")
                    .font(AppFont.caption())
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
