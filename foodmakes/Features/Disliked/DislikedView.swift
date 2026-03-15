import SwiftUI

struct DislikedView: View {
    @State private var viewModel: DislikedViewModel
    private var lm: LanguageManager { LanguageManager.shared }

    init(repository: MealRepository) {
        _viewModel = State(initialValue: DislikedViewModel(repository: repository))
    }

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if viewModel.meals.isEmpty {
                    dislikedEmpty
                } else {
                    gridContent
                }
            }
            .navigationTitle(lm.t.dislikedTitle)
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: lm.t.searchDislikedPrompt)
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

    private var gridContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filtered) { meal in
                    DislikedPinCard(
                        name: meal.name,
                        category: meal.category,
                        imageURL: meal.thumbnailURL.flatMap(URL.init)
                    ) {
                        viewModel.tapMeal(meal)
                    } onRemove: {
                        withAnimation { viewModel.remove(id: meal.id) }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 90)
        }
    }

    private var dislikedEmpty: some View {
        VStack(spacing: 14) {
            Image(systemName: "hand.thumbsdown")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color(.tertiaryLabel))
            Text(lm.t.noRejectedMeals)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
            Text(lm.t.swipeLeftHint)
                .font(.system(size: 14))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Disliked Pin Card
private struct DislikedPinCard: View {
    let name: String
    let category: String?
    let imageURL: URL?
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncMealImage(url: imageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .grayscale(0.40)
                    .saturation(0.60)
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
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if let cat = category {
                    Text(cat)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
        .onTapGesture { onTap() }
    }
}
