import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var showDetail = false
    @State private var selectedMeal: Meal?
    @State private var toastMeal: Meal?
    @State private var showToast = false
    @State private var showSettings = false
    @State private var adLoader = NativeAdLoader()
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
            .sheet(isPresented: $showSettings) {
                SettingsView(repository: viewModel.repository)
            }
            .navigationDestination(isPresented: $showDetail) {
                if let meal = selectedMeal {
                    MealDetailView(meal: meal, repository: viewModel.repository)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showToast, let meal = toastMeal {
                SwipeToast(
                    mealName: meal.name,
                    addedText: lm.t.addedToLiked,
                    goText: lm.t.goToDetail
                ) {
                    selectedMeal = meal
                    showToast = false
                    showDetail = true
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(99)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: showToast)
    }

    // MARK: - Toast helper
    private func triggerToast(for meal: Meal) {
        toastMeal = meal
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation { showToast = false }
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
            HStack(spacing: 12) {
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
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
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
                if viewModel.isAdTurn {
                    // ── Background meal cards (stacked under ad) ───────────
                    let backMeals = Array(viewModel.meals.prefix(2).reversed().enumerated())
                    ForEach(backMeals, id: \.element.id) { idx, _ in
                        let gap = CGFloat(backMeals.count - 1 - idx)
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(.secondarySystemFill))
                            .padding(.horizontal, AppSpacing.md + gap * 10)
                            .offset(y: gap * 8)
                            .scaleEffect(1 - gap * 0.03)
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                    }

                    // ── Native ad card on top ──────────────────────────────
                    NativeAdCardView(loader: adLoader) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.dismissAd()
                            // Pre-load next ad early
                            adLoader = NativeAdLoader()
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.94).combined(with: .opacity),
                        removal: .identity
                    ))
                } else {
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
                                    triggerToast(for: meal)
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
                            .onChange(of: viewModel.mealSwipesSinceLastAd) { _, newVal in
                                // Pre-load ad one swipe before it appears
                                if newVal == 5 { adLoader.load() }
                            }
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
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)
            .animation(.spring(response: 0.45, dampingFraction: 0.80), value: viewModel.meals.map(\.id))
            .animation(.spring(response: 0.45, dampingFraction: 0.80), value: viewModel.isAdTurn)
        }
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtonsSection: some View {
        if case .loaded = viewModel.loadState {
            if viewModel.isAdTurn {
                // Swipe hint shown during ad
                Text("Swipe to continue")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            } else if let topMeal = viewModel.meals.first {
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
                    // Save
                    VStack(spacing: 6) {
                        DeckButton(icon: "heart.fill", color: .tryGreen, size: 58) {
                            viewModel.swipeRight(meal: topMeal)
                            triggerToast(for: topMeal)
                        }
                        Text(lm.t.save)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                    Spacer()
                }
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

// MARK: - Swipe Toast
private struct SwipeToast: View {
    let mealName: String
    let addedText: String
    let goText: String
    let onGo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.tryGreen)

            VStack(alignment: .leading, spacing: 1) {
                Text(addedText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.label))
                Text(mealName)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Button(action: onGo) {
                HStack(spacing: 4) {
                    Text(goText)
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.warmOrange)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
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
