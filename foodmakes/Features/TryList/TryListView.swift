import SwiftUI

// MARK: - Filter Mode
enum TryListFilterMode: String, CaseIterable {
    case all, category
}

struct TryListView: View {
    @State private var viewModel: TryListViewModel
    @State private var filterMode: TryListFilterMode = .all
    private var lm: LanguageManager { LanguageManager.shared }

    init(repository: MealRepository) {
        _viewModel = State(initialValue: TryListViewModel(repository: repository))
    }

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if viewModel.meals.isEmpty {
                    tryListEmpty
                } else {
                    VStack(spacing: 0) {
                        filterPicker
                        if filterMode == .all {
                            flatContent
                        } else {
                            groupedContent
                        }
                    }
                }
            }
            .navigationTitle(lm.t.tryListTitle)
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: lm.t.searchSavedPrompt)
            .toolbar {
                if !viewModel.meals.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("\(viewModel.meals.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .onAppear { viewModel.load() }
            .navigationDestination(isPresented: $viewModel.showDetail) {
                if let meal = viewModel.selectedMealForDetail {
                    MealDetailView(meal: meal, repository: viewModel.repository)
                }
            }
        }
    }

    // MARK: - Filter Picker
    private var filterPicker: some View {
        Picker("", selection: $filterMode) {
            Text(lm.t.filterAll).tag(TryListFilterMode.all)
            Text(lm.t.filterCategories).tag(TryListFilterMode.category)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Flat (All) Content
    private var flatContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.filtered) { meal in
                    PinCard(
                        name: meal.name,
                        category: meal.category,
                        imageURL: meal.thumbnailURL.flatMap(URL.init),
                        accentColor: .tryGreen,
                        ratingScore: viewModel.ratings[meal.id]
                    ) {
                        viewModel.tapMeal(meal)
                    } onRemove: {
                        withAnimation { viewModel.remove(id: meal.id) }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 90)
        }
    }

    // MARK: - Grouped (Category) Content
    private var groupedContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.groupedFiltered, id: \.key) { group in
                    Section {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(group.meals) { meal in
                                PinCard(
                                    name: meal.name,
                                    category: meal.category,
                                    imageURL: meal.thumbnailURL.flatMap(URL.init),
                                    accentColor: .tryGreen,
                                    ratingScore: viewModel.ratings[meal.id]
                                ) {
                                    viewModel.tapMeal(meal)
                                } onRemove: {
                                    withAnimation { viewModel.remove(id: meal.id) }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    } header: {
                        let title = group.key.isEmpty ? lm.t.categoryOther : group.key
                        Text(title.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .kerning(1.2)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground).opacity(0.94))
                    }
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 90)
        }
    }

    private var tryListEmpty: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color(.tertiaryLabel))
            Text(lm.t.nothingSavedYet)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
            Text(lm.t.swipeRightHint)
                .font(.system(size: 14))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Pinterest Pin Card (shared)
struct PinCard: View {
    let name: String
    let category: String?
    let imageURL: URL?
    let accentColor: Color
    var ratingScore: Int? = nil
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                AsyncMealImage(url: imageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipped()

                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(Color(.label))
                        .frame(width: 22, height: 22)
                        .background(Color(.systemBackground).opacity(0.90))
                        .clipShape(Circle())
                }
                .padding(8)

                // Star rating badge (bottom-left of image)
                if let score = ratingScore {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("\(score)")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color.warmOrange.opacity(0.90))
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity,
                           alignment: .bottomLeading)
                    .padding(8)
                }
            }

            // Text below image
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if let cat = category {
                    Text(cat)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 3)
        .onTapGesture { onTap() }
    }
}
