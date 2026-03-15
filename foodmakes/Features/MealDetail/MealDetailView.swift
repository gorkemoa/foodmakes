import SwiftUI

struct MealDetailView: View {
    @State private var viewModel: MealDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var heartScale: CGFloat = 1
    @State private var ratingExpanded = false

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

            // ── Plan toast ───────────────────────────────────────────────────────
            if viewModel.showPlanToast, let msg = viewModel.planToastMessage {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.deepBrown.opacity(0.92))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.20), radius: 16, x: 0, y: 8)
                        .padding(.bottom, 48)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.showPlanToast)
        .navigationBarHidden(true)
        .task { await viewModel.loadDetailIfNeeded() }
        .sheet(isPresented: $viewModel.showAddToPlanSheet) {
            AddToPlanSheet(mealName: viewModel.meal.name) { date in
                viewModel.addToPlan(date: date)
            }
        }
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
                    text: String(format: lm.t.ingredientsCountFormat, viewModel.meal.ingredients.count),
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

            // Links (Watch & Read) — moved above instructions
            linksSection

            // Instructions
            if let instructions = viewModel.meal.instructions, !instructions.isEmpty {
                instructionsSection(instructions)
            } else if viewModel.isLoadingDetail {
                detailLoadingIndicator
            }

            // Rating
            ratingSection

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
            DetailSectionHeader(
                title: lm.t.howToCook, badge: String(format: lm.t.stepsCountFormat, steps.count))
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

    // MARK: - Rating Section (Accordion)
    @ViewBuilder
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row — always visible
            Button {
                withAnimation(.spring(response: 0.36, dampingFraction: 0.78)) {
                    ratingExpanded.toggle()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.warmOrange)

                    if let r = viewModel.rating {
                        Text(lm.t.yourRating)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= r.overallScore ? "star.fill" : "star")
                                    .font(.system(size: 12))
                                    .foregroundStyle(i <= r.overallScore ? Color.warmOrange : Color(.tertiaryLabel))
                            }
                        }
                    } else {
                        Text(lm.t.rateMeal)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .rotationEffect(.degrees(ratingExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // Expanded body
            if ratingExpanded {
                RatingAccordionBody(
                    existing: viewModel.rating,
                    lm: lm,
                    onSave: { overall, taste, eatAgain, recommend in
                        viewModel.saveRating(
                            overallScore: overall,
                            tasteScore: taste,
                            wouldEatAgain: eatAgain,
                            wouldRecommend: recommend
                        )
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.78)) {
                            ratingExpanded = false
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

            HStack(spacing: 10) {
                // Calendar / Add-to-plan button
                Button { viewModel.showAddToPlanSheet = true } label: {
                    Image(systemName: viewModel.isPlanned ? "calendar.badge.checkmark" : "calendar.badge.plus")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(viewModel.isPlanned ? Color.warmOrange : Color(.label))
                        .frame(width: 40, height: 40)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 3)
                }

                // Heart / Try-list button
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

// MARK: - Rating Accordion Body
private struct RatingAccordionBody: View {
    let existing: PersistedMealRating?
    let lm: LanguageManager
    let onSave: (Int, Int, Bool, Bool) -> Void

    @State private var overallScore: Int = 3
    @State private var tasteScore: Int = 3
    @State private var wouldEatAgain: Bool = true
    @State private var wouldRecommend: Bool = true

    var body: some View {
        VStack(spacing: 14) {
            Divider()

            ratingRow(title: lm.t.overallScore, icon: "star.fill", score: $overallScore)
            ratingRow(title: lm.t.tasteScore, icon: "fork.knife", score: $tasteScore)
            toggleRow(title: lm.t.wouldEatAgain, value: $wouldEatAgain,
                      trueIcon: "checkmark", falseIcon: "xmark")
            toggleRow(title: lm.t.wouldRecommend, value: $wouldRecommend,
                      trueIcon: "hand.thumbsup.fill", falseIcon: "hand.thumbsdown.fill")

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onSave(overallScore, tasteScore, wouldEatAgain, wouldRecommend)
            } label: {
                Text(lm.t.saveRating)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.warmOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            if let r = existing {
                overallScore = r.overallScore
                tasteScore = r.tasteScore
                wouldEatAgain = r.wouldEatAgain
                wouldRecommend = r.wouldRecommend
            }
        }
    }

    private func ratingRow(title: String, icon: String, score: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.warmOrange)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text("\(score.wrappedValue)/5")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.warmOrange)
            }
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            score.wrappedValue = i
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: i <= score.wrappedValue ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundStyle(i <= score.wrappedValue ? Color.warmOrange : Color(.tertiaryLabel))
                            .scaleEffect(i == score.wrappedValue ? 1.15 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: score.wrappedValue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toggleRow(title: String, value: Binding<Bool>,
                           trueIcon: String, falseIcon: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            HStack(spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { value.wrappedValue = true }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: trueIcon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(value.wrappedValue ? .white : Color(.tertiaryLabel))
                        .frame(width: 46, height: 34)
                        .background(value.wrappedValue ? Color.tryGreen : Color(.tertiarySystemFill))
                }
                .buttonStyle(.plain)
                Button {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { value.wrappedValue = false }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: falseIcon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(!value.wrappedValue ? .white : Color(.tertiaryLabel))
                        .frame(width: 46, height: 34)
                        .background(!value.wrappedValue ? Color.dislikeRed : Color(.tertiarySystemFill))
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
    }
}

