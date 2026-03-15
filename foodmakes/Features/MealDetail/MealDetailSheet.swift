import SwiftUI

// MARK: - Meal Detail Bottom Sheet
struct MealDetailSheet: View {
    @State private var viewModel: MealDetailViewModel
    private let repository: MealRepository
    @Environment(\.dismiss) private var dismiss
    @State private var showFullDetail = false

    // Staggered entrance state
    @State private var headerVisible  = false
    @State private var chipsVisible   = false
    @State private var dividerVisible = false
    @State private var ingrVisible    = false
    @State private var stepsVisible   = false
    @State private var ctaVisible     = false

    @State private var heartScale: CGFloat = 1

    init(meal: Meal, repository: MealRepository) {
        _viewModel = State(initialValue: MealDetailViewModel(meal: meal, repository: repository))
        self.repository = repository
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage
                    contentBody
                }
            }
            .background(Color(.systemBackground))
            .navigationDestination(isPresented: $showFullDetail) {
                MealDetailView(meal: viewModel.meal, repository: repository)
            }
        }
        .task {
            await viewModel.loadDetailIfNeeded()
            animateIn()
        }
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
            // Meal name
            Text(viewModel.meal.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 12)

            // Area / ingredient count chips
            HStack(spacing: 8) {
                if let area = viewModel.meal.area {
                    SheetChip(icon: "mappin", text: area)
                }
                SheetChip(
                    icon: "list.bullet",
                    text: "\(viewModel.meal.ingredients.count) ingredients"
                )
            }
            .opacity(chipsVisible ? 1 : 0)
            .offset(y: chipsVisible ? 0 : 8)

            // Divider
            Rectangle()
                .fill(Color(.separator).opacity(0.45))
                .frame(height: 1)
                .opacity(dividerVisible ? 1 : 0)

            // Ingredients
            if !viewModel.meal.ingredients.isEmpty {
                ingredientsSection
                    .opacity(ingrVisible ? 1 : 0)
                    .offset(y: ingrVisible ? 0 : 10)
            }

            // Instructions
            if let instructions = viewModel.meal.instructions, !instructions.isEmpty {
                instructionsSection(instructions)
                    .opacity(stepsVisible ? 1 : 0)
                    .offset(y: stepsVisible ? 0 : 10)
            } else if viewModel.isLoadingDetail {
                loadingRow
                    .opacity(ingrVisible ? 1 : 0)
            }

            // View full recipe CTA
            Button {
                showFullDetail = true
            } label: {
                HStack(spacing: 8) {
                    Text("View Full Recipe")
                        .font(.system(size: 15, weight: .semibold))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.warmOrange)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 8)

            Color.clear.frame(height: 24)
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
    }

    // MARK: - Ingredients
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredients")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 5) {
                ForEach(viewModel.meal.ingredients) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color.warmOrange)
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)
                        Text(item.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 8)
                        Text(item.measure)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
            }
        }
    }

    // MARK: - Instructions (brief, first 3 steps)
    private func instructionsSection(_ raw: String) -> some View {
        let all = raw
            .components(separatedBy: .init(charactersIn: "\r\n."))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 10 }
        let preview = Array(all.prefix(3))

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("How to Cook")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                if all.count > 3 {
                    Text("+\(all.count - 3) more steps")
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
                        Text(step)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
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
            Text("Loading recipe…")
                .font(.system(size: 13))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Staggered animation
    private func animateIn() {
        let spring = Animation.spring(response: 0.44, dampingFraction: 0.78)
        withAnimation(spring.delay(0.05))  { headerVisible  = true }
        withAnimation(spring.delay(0.12))  { chipsVisible   = true }
        withAnimation(spring.delay(0.18))  { dividerVisible = true }
        withAnimation(spring.delay(0.24))  { ingrVisible    = true }
        withAnimation(spring.delay(0.34))  { stepsVisible   = true }
        withAnimation(spring.delay(0.42))  { ctaVisible     = true }
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

