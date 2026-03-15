import SwiftUI

// MARK: - Meal Rating Sheet
struct MealRatingSheet: View {
    let meal: Meal
    let existingRating: PersistedMealRating?
    let onSave: (Int, Int, Bool, Bool) -> Void

    @State private var overallScore: Int = 3
    @State private var tasteScore: Int = 3
    @State private var wouldEatAgain: Bool = true
    @State private var wouldRecommend: Bool = true
    @Environment(\.dismiss) private var dismiss
    private var lm: LanguageManager { LanguageManager.shared }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Meal thumbnail header
                    AsyncMealImage(url: meal.thumbnailLink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                        .overlay(alignment: .bottom) {
                            LinearGradient(
                                colors: [.clear, Color(.systemBackground)],
                                startPoint: .top, endPoint: .bottom
                            )
                            .frame(height: 60)
                        }

                    VStack(spacing: 16) {
                        Text(meal.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        // Overall score
                        ratingRow(
                            title: lm.t.overallScore,
                            icon: "star.fill",
                            score: $overallScore
                        )

                        // Taste score
                        ratingRow(
                            title: lm.t.tasteScore,
                            icon: "fork.knife",
                            score: $tasteScore
                        )

                        // Would eat again
                        toggleRow(
                            title: lm.t.wouldEatAgain,
                            value: $wouldEatAgain,
                            trueIcon: "checkmark",
                            falseIcon: "xmark"
                        )

                        // Would recommend
                        toggleRow(
                            title: lm.t.wouldRecommend,
                            value: $wouldRecommend,
                            trueIcon: "hand.thumbsup.fill",
                            falseIcon: "hand.thumbsdown.fill"
                        )

                        // Save button
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onSave(overallScore, tasteScore, wouldEatAgain, wouldRecommend)
                            dismiss()
                        } label: {
                            Text(lm.t.saveRating)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.warmOrange)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(.top, 4)

                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 4)
                }
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle(lm.t.yourRating)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .frame(width: 30, height: 30)
                            .background(Color(.secondarySystemFill))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .onAppear {
            if let r = existingRating {
                overallScore = r.overallScore
                tasteScore = r.tasteScore
                wouldEatAgain = r.wouldEatAgain
                wouldRecommend = r.wouldRecommend
            }
        }
    }

    // MARK: - Rating Row (star selector)
    private func ratingRow(title: String, icon: String, score: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.warmOrange)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            score.wrappedValue = i
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: i <= score.wrappedValue ? "star.fill" : "star")
                            .font(.system(size: 34))
                            .foregroundStyle(i <= score.wrappedValue ? Color.warmOrange : Color(.tertiaryLabel))
                            .scaleEffect(i == score.wrappedValue ? 1.15 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: score.wrappedValue)
                    }
                }
                Spacer()
                Text("\(score.wrappedValue)/5")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.warmOrange)
                    .frame(width: 36)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Toggle Row (yes/no)
    private func toggleRow(title: String, value: Binding<Bool>,
                           trueIcon: String, falseIcon: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            HStack(spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { value.wrappedValue = true }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: trueIcon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(value.wrappedValue ? .white : Color(.tertiaryLabel))
                        .frame(width: 52, height: 38)
                        .background(value.wrappedValue ? Color.tryGreen : Color(.tertiarySystemFill))
                }
                Button {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { value.wrappedValue = false }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: falseIcon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(!value.wrappedValue ? .white : Color(.tertiaryLabel))
                        .frame(width: 52, height: 38)
                        .background(!value.wrappedValue ? Color.dislikeRed : Color(.tertiarySystemFill))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
