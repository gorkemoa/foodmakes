import SwiftUI

struct MealDetailView: View {
    @State private var viewModel: MealDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var heartScale: CGFloat = 1

    private let heroHeight: CGFloat = 420
    private var lm: LanguageManager { LanguageManager.shared }

    init(meal: Meal, repository: MealRepository) {
        _viewModel = State(initialValue: MealDetailViewModel(meal: meal, repository: repository))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // ── Scrollable body ──────────────────────────────────────────
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    metadataStrip
                    contentSection
                }
            }
            .ignoresSafeArea(edges: .top)
            .coordinateSpace(name: "scroll")

            // ── Floating nav row ─────────────────────────────────────────
            floatingNavBar
        }
        .navigationBarHidden(true)
        .task { await viewModel.loadDetailIfNeeded() }
    }

    // MARK: - Hero
    private var heroSection: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .named("scroll")).minY
            let isStretching = minY > 0

            AsyncMealImage(url: viewModel.meal.thumbnailLink)
                .frame(
                    width: geo.size.width,
                    height: isStretching ? heroHeight + minY : heroHeight
                )
                .offset(y: isStretching ? -minY : 0)
                .overlay(AppGradient.heroFade)
                .overlay(alignment: .bottom) {
                    heroTitleOverlay
                }
        }
        .frame(height: heroHeight)
    }

    private var heroTitleOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status pill
            HStack(spacing: 8) {
                if viewModel.isInTryList {
                    StatusPill(text: lm.t.savedToTryList, icon: "heart.fill", color: .tryGreen)
                }
                if viewModel.isDisliked {
                    StatusPill(text: lm.t.dislikedLabel, icon: "hand.thumbsdown.fill", color: .dislikeRed)
                }
            }

            TranslatedText(original: viewModel.meal.name,
                           font: .system(size: 32, weight: .black, design: .rounded),
                           color: .white,
                           lineLimit: 3)
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.bottom, 28)
    }

    // MARK: - Metadata Strip (tags)
    private var metadataStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = viewModel.meal.category {
                    MetaChip(icon: "flame.fill",      text: category,   color: Color.warmOrange)
                }
                if let area = viewModel.meal.area {
                    MetaChip(icon: "globe.europe.africa.fill", text: area, color: Color.warmGold)
                }
                MetaChip(
                    icon: "list.bullet.clipboard",
                    text: "\(viewModel.meal.ingredients.count) ingredients",
                    color: Color.blue
                )
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Content
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Ingredients
            if !viewModel.meal.ingredients.isEmpty {
                ingredientsSection
            }

            // Instructions
            if let instructions = viewModel.meal.instructions, !instructions.isEmpty {
                instructionsSection(instructions)
            } else if viewModel.isLoadingDetail {
                detailLoadingIndicator
            }

            // Links
            linksSection

            Color.clear.frame(height: 80)
        }
        .padding(.horizontal, 22)
        .padding(.top, 6)
        .background(Color(.systemBackground))
    }

    // MARK: - Ingredients
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            DetailSectionHeader(
                title: lm.t.ingredients,
                badge: "\(viewModel.meal.ingredients.count)"
            )

            VStack(spacing: 6) {
                ForEach(viewModel.meal.ingredients) { item in
                    IngredientRow(item: item)
                }
            }
        }
    }

    // MARK: - Instructions
    private func instructionsSection(_ text: String) -> some View {
        let steps = text
            .components(separatedBy: .init(charactersIn: "\r\n."))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 10 }

        return VStack(alignment: .leading, spacing: 14) {
            DetailSectionHeader(title: lm.t.howToCook, badge: "\(steps.count) steps")
            VStack(spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                    CookingStepCard(index: i + 1, text: step)
                }
            }
        }
    }

    private var detailLoadingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView().tint(.warmOrange)
            Text(lm.t.loadingRecipe)
                .font(.system(size: 14))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    // MARK: - External Links
    @ViewBuilder
    private var linksSection: some View {
        let hasYt  = viewModel.meal.youtubeLink != nil
        let hasSrc = viewModel.meal.sourceLink  != nil
        if hasYt || hasSrc {
            VStack(alignment: .leading, spacing: 14) {
                DetailSectionHeader(title: lm.t.watchAndRead)
                HStack(spacing: 10) {
                    if let yt = viewModel.meal.youtubeLink {
                        LinkButton(icon: "play.circle.fill", label: lm.t.watchOnYoutube, color: Color.red, url: yt)
                    }
                    if let src = viewModel.meal.sourceLink {
                        LinkButton(icon: "safari.fill", label: lm.t.originalRecipe, color: Color.warmOrange, url: src)
                    }
                }
            }
        }
    }

    // MARK: - Floating NAV bar
    private var floatingNavBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .frame(width: 40, height: 40)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 3)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { heartScale = 1.4 }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.12)) { heartScale = 1 }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                viewModel.toggleTryList()
            } label: {
                Image(systemName: viewModel.isInTryList ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(viewModel.isInTryList ? Color.tryGreen : Color(.label))
                    .scaleEffect(heartScale)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
    }
}

// MARK: - Status Pill
private struct StatusPill: View {
    let text: String; let icon: String; let color: Color
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 10, weight: .semibold))
            Text(text).font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(color)
        .clipShape(Capsule())
    }
}

// MARK: - Meta Chip
private struct MetaChip: View {
    let icon: String; let text: String; let color: Color
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Color(.secondarySystemFill))
        .clipShape(Capsule())
    }
}

// MARK: - Detail Section Header
private struct DetailSectionHeader: View {
    let title: String
    var badge: String? = nil
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
            if let badge {
                Text(badge)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.warmOrange)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.warmOrange.opacity(0.12))
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }
}

// MARK: - Ingredient Row (single column, no truncation)
private struct IngredientRow: View {
    let item: IngredientItem
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.warmOrange)
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            TranslatedText(original: item.name,
                           font: .system(size: 14, weight: .medium),
                           color: Color.textPrimary,
                           fixedVertical: true)
            Spacer(minLength: 8)
            Text(item.measure)
                .font(.system(size: 13))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Ingredient Chip (kept for any backward use)
private struct IngredientChip: View {
    let item: IngredientItem
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.warmOrange)
                .frame(width: 5, height: 5)
            Text(item.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(item.measure)
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Cooking Step Card
private struct CookingStepCard: View {
    let index: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(index)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.warmOrange)
                .frame(width: 24, height: 24)
                .background(Color.warmOrange.opacity(0.10))
                .clipShape(Circle())

            TranslatedText(original: text,
                           font: .system(size: 14),
                           color: Color.textPrimary,
                           fixedVertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 3)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Link Button
private struct LinkButton: View {
    let icon: String; let label: String; let color: Color; let url: URL
    var body: some View {
        Link(destination: url) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(color)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(color.opacity(0.25), lineWidth: 1)
            )
        }
    }
}

