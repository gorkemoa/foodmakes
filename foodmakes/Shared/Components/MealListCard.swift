import SwiftUI

// MARK: - Compact Meal Card (used in lists: Try List, Disliked)
struct MealListCard: View {
    let meal: PersistedTryMeal
    var onTap: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Thumbnail
            AsyncMealImage(url: meal.thumbnailURL.flatMap(URL.init))
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))

            // Info
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(meal.name)
                    .font(AppFont.headlineSmall(.semibold))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)

                HStack(spacing: AppSpacing.xxs) {
                    if let category = meal.category {
                        TagBadge(text: category, icon: "tag.fill")
                    }
                    if let area = meal.area {
                        TagBadge(text: area, icon: "map.fill", color: .warmGold)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Remove
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.sm)
        .background(.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .appShadow(AppShadow.cardSoft)
        .onTapGesture { onTap?() }
    }
}

// MARK: - Compact Disliked Card
struct DislikedListCard: View {
    let meal: PersistedDislikedMeal
    var onTap: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncMealImage(url: meal.thumbnailURL.flatMap(URL.init))
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                .grayscale(0.3)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(meal.name)
                    .font(AppFont.headlineSmall(.semibold))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)

                HStack(spacing: AppSpacing.xxs) {
                    if let category = meal.category {
                        TagBadge(text: category, icon: "tag.fill", color: .dislikeRed.opacity(0.8))
                    }
                    if let area = meal.area {
                        TagBadge(text: area, icon: "map.fill", color: .secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.sm)
        .background(.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .appShadow(AppShadow.cardSoft)
        .onTapGesture { onTap?() }
    }
}
