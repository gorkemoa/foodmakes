import SwiftUI

// MARK: - Swipe Card View
struct SwipeCardView: View {
    let meal: Meal
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    let onTap: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var cardAppeared = false

    private let swipeThreshold: CGFloat = 110
    private var lm: LanguageManager { LanguageManager.shared }

    private var tryOpacity: Double  { max(0, Double(dragOffset.width  / swipeThreshold) - 0.05) }
    private var nopeOpacity: Double { max(0, Double(-dragOffset.width / swipeThreshold) - 0.05) }
    private var rotation: Double    { Double(dragOffset.width / 20) }
    private var liftY: CGFloat      { -abs(dragOffset.width) * 0.03 }

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Full-bleed food photo ──────────────────────────────────────
            AsyncMealImage(url: meal.thumbnailLink)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Minimal bottom scrim ───────────────────────────────────────
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.32),
                    .init(color: .black.opacity(0.58), location: 1)
                ],
                startPoint: .top, endPoint: .bottom
            )

            // ── Swipe direction stamps ─────────────────────────────────────
            VStack {
                HStack {
                    SwipeLabel(text: lm.t.nopeStamp, color: .dislikeRed, angle: -13)
                        .opacity(nopeOpacity)
                        .scaleEffect(0.85 + nopeOpacity * 0.15)
                        .padding(.leading, 24)
                    Spacer()
                    SwipeLabel(text: lm.t.tryStamp, color: .tryGreen, angle: 13)
                        .opacity(tryOpacity)
                        .scaleEffect(0.85 + tryOpacity * 0.15)
                        .padding(.trailing, 24)
                }
                .padding(.top, 60)
                Spacer()
            }

            // ── Clean text info at bottom ──────────────────────────────────
            VStack(alignment: .leading, spacing: 5) {
                if let cat = meal.category {
                    Text(cat.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .kerning(1.8)
                        .foregroundStyle(.white.opacity(0.70))
                        .lineLimit(1)
                }
                Text(meal.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                if let area = meal.area {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 9))
                        Text(area)
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.top, 1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.13), radius: 20, x: 0, y: 8)
        .rotationEffect(.degrees(rotation))
        .offset(y: liftY)
        .offset(dragOffset)
        .scaleEffect(cardAppeared ? 1 : 0.92)
        .opacity(cardAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.50, dampingFraction: 0.75)) {
                cardAppeared = true
            }
        }
        .gesture(
            DragGesture(minimumDistance: 6)
                .onChanged { value in
                    withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.86)) {
                        dragOffset = value.translation
                        isDragging = true
                    }
                }
                .onEnded { value in
                    isDragging = false
                    let vx = value.predictedEndTranslation.width
                    if vx < -swipeThreshold {
                        triggerSwipe(direction: .left)
                    } else if vx > swipeThreshold {
                        triggerSwipe(direction: .right)
                    } else {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.68)) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .onTapGesture {
            guard abs(dragOffset.width) < 8 else { return }
            onTap()
        }
    }

    // MARK: - Swipe trigger
    private func triggerSwipe(direction: SwipeDirection) {
        let fb = UIImpactFeedbackGenerator(style: .medium)
        fb.impactOccurred()
        let targetX: CGFloat = direction == .left ? -700 : 700
        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
            dragOffset = CGSize(width: targetX, height: dragOffset.height * 0.4 - 20)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            if direction == .left { onSwipeLeft() } else { onSwipeRight() }
        }
    }
}

// MARK: - Stamp Label
private struct SwipeLabel: View {
    let text: String; let color: Color; let angle: Double

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .rotationEffect(.degrees(angle))
    }
}
