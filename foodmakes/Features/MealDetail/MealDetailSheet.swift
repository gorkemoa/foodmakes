import SwiftUI

// MARK: - Meal Detail Bottom Sheet
struct MealDetailSheet: View {
    @State private var viewModel: MealDetailViewModel
    private let repository: MealRepository
    @Environment(\.dismiss) private var dismiss
    @State private var showFullDetail = false
    @State private var heartScale: CGFloat = 1
    @AppStorage("fm_sheet_tutorial_seen") private var tutorialSeen: Bool = false
    @State private var showTutorial = false

    init(meal: Meal, repository: MealRepository) {
        _viewModel = State(initialValue: MealDetailViewModel(meal: meal, repository: repository))
        self.repository = repository
    }

    private var lm: LanguageManager { LanguageManager.shared }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topActionStrip
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        heroImage
                        contentBody
                    }
                }
            }
            .background(Color(.systemBackground))
            .overlay(alignment: .top) {
                if showTutorial {
                    tutorialBanner
                        .padding(.top, 64)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .overlay(alignment: .bottom) {
                if viewModel.showPlanToast, let msg = viewModel.planToastMessage {
                    Text(msg)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.label).opacity(0.88))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.showPlanToast)
            .navigationDestination(isPresented: $showFullDetail) {
                MealDetailView(meal: viewModel.meal, repository: repository)
            }
            .sheet(isPresented: $viewModel.showAddToPlanSheet) {
                AddToPlanSheet(mealName: viewModel.meal.name) { date, time1, time2 in
                    viewModel.addToPlan(date: date, time1: time1, time2: time2)
                }
            }
        }
        .task { await viewModel.loadDetailIfNeeded() }
        .onAppear {
            guard !tutorialSeen else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showTutorial = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation(.easeOut(duration: 0.35)) { showTutorial = false }
                    tutorialSeen = true
                }
            }
        }
    }

    // MARK: - Top Action Strip
    private var topActionStrip: some View {
        HStack(spacing: 12) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .frame(width: 34, height: 34)
                    .background(Color(.secondarySystemFill))
                    .clipShape(Circle())
            }
            Spacer()
            // Calendar / Add-to-plan
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                viewModel.showAddToPlanSheet = true
            } label: {
                Image(systemName: viewModel.isPlanned ? "calendar.badge.checkmark" : "calendar.badge.plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(viewModel.isPlanned ? Color.warmOrange : Color(.label))
                    .frame(width: 34, height: 34)
                    .background(Color(.secondarySystemFill))
                    .clipShape(Circle())
            }
            Button { showFullDetail = true } label: {
                HStack(spacing: 6) {
                    Text(lm.t.viewFullRecipe)
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(Color.warmOrange)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Tutorial Banner
    private var tutorialBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.down")
                .font(.system(size: 11, weight: .bold))
            Text(lm.t.sheetDismissHint)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .background(Color(.label).opacity(0.82))
        .clipShape(Capsule())
    }

    // MARK: - Hero Image
    private var heroImage: some View {
        AsyncMealImage(url: viewModel.meal.thumbnailLink)
            .frame(maxWidth: .infinity)
            .frame(height: 210)
            .clipped()
            .overlay(alignment: .topTrailing) { heartButton }
            .overlay(alignment: .bottomLeading) { categoryBadge }
    }

    private var heartButton: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) { heartScale = 1.45 }
            withAnimation(.spring(response: 0.28, dampingFraction: 0.6).delay(0.12)) { heartScale = 1 }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            viewModel.toggleTryList()
        } label: {
            Image(systemName: viewModel.isInTryList ? "heart.fill" : "heart")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(viewModel.isInTryList ? Color.tryGreen : .white)
                .scaleEffect(heartScale)
                .frame(width: 38, height: 38)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .padding(14)
    }

    private var categoryBadge: some View {
        Group {
            if let cat = viewModel.meal.category {
                Text(cat.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .kerning(1.4)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.35))
                    .clipShape(Capsule())
                    .padding(14)
            }
        }
    }

    // MARK: - Content
    private var contentBody: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Meal name — always visible immediately
            TranslatedText(original: viewModel.meal.name,
                           font: .system(size: 24, weight: .bold, design: .rounded),
                           color: Color.textPrimary,
                           fixedVertical: true)

            // Area / ingredient count chips
            HStack(spacing: 8) {
                if let area = viewModel.meal.area {
                    SheetChip(icon: "mappin", text: area)
                }
                SheetChip(
                    icon: "list.bullet",
                    text: String(format: lm.t.ingredientsCountFormat, viewModel.meal.ingredients.count)
                )
            }

            Rectangle()
                .fill(Color(.separator).opacity(0.45))
                .frame(height: 1)

            // Ingredients — always visible (data comes with the initial card)
            if !viewModel.meal.ingredients.isEmpty {
                ingredientsSection
            }

            // Instructions — animate in when they arrive from network
            if let instructions = viewModel.meal.instructions, !instructions.isEmpty {
                instructionsSection(instructions)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if viewModel.isLoadingDetail {
                loadingRow
            }

            Color.clear.frame(height: 24)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.80), value: viewModel.meal.instructions != nil)
        .padding(.horizontal, 22)
        .padding(.top, 18)
    }

    // MARK: - Ingredients
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lm.t.ingredients)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 5) {
                ForEach(viewModel.meal.ingredients) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color.warmOrange)
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)
                        TranslatedText(original: item.name,
                                       font: .system(size: 13, weight: .medium),
                                       color: Color.textPrimary,
                                       fixedVertical: true)
                        Spacer(minLength: 8)
                        TranslatedText(original: item.measure,
                                       font: .system(size: 12),
                                       color: Color.textSecondary,
                                       fixedVertical: true)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
            }
        }
    }

    // MARK: - Instructions (first 3 steps preview)
    private func instructionsSection(_ raw: String) -> some View {
        let all = raw
            .components(separatedBy: .init(charactersIn: "\r\n."))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 10 }
        let preview = Array(all.prefix(3))

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(lm.t.howToCook)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                if all.count > 3 {
                    Text(String(format: lm.t.moreStepsFormat, all.count - 3))
                        .font(.system(size: 11))
                        .foregroundStyle(Color.warmOrange)
                }
            }

            VStack(spacing: 6) {
                ForEach(Array(preview.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(i + 1)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.warmOrange)
                            .frame(width: 22, height: 22)
                            .background(Color.warmOrange.opacity(0.10))
                            .clipShape(Circle())
                        TranslatedText(original: step,
                                       font: .system(size: 13),
                                       color: Color.textPrimary,
                                       fixedVertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 2)
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }

    private var loadingRow: some View {
        HStack(spacing: 10) {
            ProgressView().tint(Color.warmOrange)
            Text(lm.t.loadingRecipe)
                .font(.system(size: 13))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Sheet Chip
private struct SheetChip: View {
    let icon: String; let text: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.warmOrange)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(.secondarySystemFill))
        .clipShape(Capsule())
    }
}

