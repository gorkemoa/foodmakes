import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var showDetail = false
    @State private var selectedMeal: Meal?
    @State private var sheetMeal: Meal?
    @State private var showSheet = false
    private var lm: LanguageManager { LanguageManager.shared }

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                cardDeckSection

                actionButtonsSection
                    .padding(.top, 18)
                    .padding(.bottom, 24)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .task { await viewModel.loadMeals() }
            .navigationDestination(isPresented: $showDetail) {
                if let meal = selectedMeal {
                    MealDetailView(meal: meal, repository: viewModel.repository)
                }
            }
            .sheet(isPresented: $showSheet) {
                if let meal = sheetMeal {
                    MealDetailSheet(meal: meal, repository: viewModel.repository)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("FoodMakes")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Text(lm.t.appTagline)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .kerning(0.1)
            }
            Spacer()
            if case .loaded = viewModel.loadState, !viewModel.meals.isEmpty {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(viewModel.meals.count)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                    Text(lm.t.mealsLeft)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    // MARK: - Card Deck
    @ViewBuilder
    private var cardDeckSection: some View {
        switch viewModel.loadState {
        case .loading, .idle:
            HomeLoadingView()
                .frame(height: cardHeight)

        case .failed(let msg):
            ErrorView(message: msg) {
                Task { await viewModel.loadMeals() }
            }
            .frame(height: cardHeight)

        case .empty:
            HomeEmptyView { Task { await viewModel.loadMeals() } }
                .frame(height: cardHeight)

        case .loaded:
            ZStack {
                let visible = Array(viewModel.meals.prefix(3).reversed().enumerated())
                ForEach(visible, id: \.element.id) { idx, meal in
                    let depth = CGFloat(idx)
                    let total = CGFloat(min(viewModel.meals.count, 3))
                    let isTop = idx == Int(total) - 1

                    if isTop {
                        SwipeCardView(
                            meal: meal,
                            onSwipeLeft:  { viewModel.swipeLeft(meal: meal) },
                            onSwipeRight: {
                                viewModel.swipeRight(meal: meal)
                                sheetMeal = meal
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                                    showSheet = true
                                }
                            },
                            onTap: {
                                selectedMeal = meal
                                showDetail = true
                            }
                        )
                        .padding(.horizontal, AppSpacing.md)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.94).combined(with: .opacity),
                            removal: .identity
                        ))
                    } else {
                        let gap = total - 1 - depth
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(.secondarySystemFill))
                            .padding(.horizontal, AppSpacing.md + gap * 10)
                            .offset(y: gap * 8)
                            .scaleEffect(1 - gap * 0.03)
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)
            .animation(.spring(response: 0.45, dampingFraction: 0.80), value: viewModel.meals.map(\.id))
        }
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtonsSection: some View {
        if case .loaded = viewModel.loadState, let topMeal = viewModel.meals.first {
            HStack(spacing: 0) {
                Spacer()
                // Skip
                VStack(spacing: 6) {
                    DeckButton(icon: "xmark", color: .dislikeRed, size: 58) {
                        viewModel.swipeLeft(meal: topMeal)
                    }
                    Text(lm.t.skip)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                // Full detail
                DeckButton(icon: "arrow.up.right", color: Color(.tertiaryLabel), size: 44) {
                    selectedMeal = topMeal
                    showDetail = true
                }
                Spacer()
                // Save + sheet
                VStack(spacing: 6) {
                    DeckButton(icon: "heart.fill", color: .tryGreen, size: 58) {
                        viewModel.swipeRight(meal: topMeal)
                        sheetMeal = topMeal
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                            showSheet = true
                        }
                    }
                    Text(lm.t.save)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
            }
        }
    }

    private var cardHeight: CGFloat {
        UIScreen.main.bounds.height * 0.56
    }
}

// MARK: - Deck Action Button
private struct DeckButton: View {
    let icon: String; let color: Color; let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 4)
                    .overlay(Circle().strokeBorder(color.opacity(0.22), lineWidth: 1.5))
                Image(systemName: icon)
                    .font(.system(size: size * 0.30, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Loading
private struct HomeLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.warmOrange)
                .scaleEffect(1.2)
            Text("Finding meals…")
                .font(.system(size: 14))
                .foregroundStyle(Color.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Empty
private struct HomeEmptyView: View {
    let onReload: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🍽")
                .font(.system(size: 52))
            VStack(spacing: 6) {
                Text("All caught up!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                Text("You've swiped through every meal in this batch.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Button(action: onReload) {
                Text("Load More")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 13)
                    .background(Color.warmOrange)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }
}
