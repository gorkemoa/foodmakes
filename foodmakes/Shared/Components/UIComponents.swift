import SwiftUI

// MARK: - Primary Action Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(AppFont.headlineSmall(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(AppGradient.orangePrimary)
            .clipShape(Capsule())
            .appShadow(AppShadow.button)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Circular Icon Button (action deck buttons)
struct CircularActionButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void

    init(icon: String, color: Color, size: CGFloat = 56, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .strokeBorder(color.opacity(0.25), lineWidth: 1.5)
                    )
                    .shadow(color: color.opacity(0.20), radius: 10, x: 0, y: 5)
                Image(systemName: icon)
                    .font(.system(size: size * 0.36, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tag Badge
struct TagBadge: View {
    let text: String
    let icon: String?
    var color: Color = .warmOrange

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(AppFont.captionSmall(.semibold))
            }
            Text(text)
                .font(AppFont.captionSmall(.semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppFont.headlineLarge())
                .foregroundStyle(.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(AppFont.bodySmall())
                    .foregroundStyle(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let onAction: (() -> Void)?

    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.onAction = onAction
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.warmOrange.opacity(0.10))
                    .frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Color.warmOrange.opacity(0.7))
            }
            VStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFont.displaySmall())
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(AppFont.bodyMedium())
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            if let actionTitle, let onAction {
                PrimaryButton(actionTitle, icon: "arrow.clockwise", action: onAction)
                    .padding(.top, AppSpacing.xs)
            }
            Spacer()
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var message: String = "Fetching meals..."

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.warmOrange.opacity(0.10))   
                    .frame(width: 84, height: 84)
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.warmOrange)
                    .scaleEffect(1.3)
            }
            Text(message)
                .font(AppFont.bodyMedium())
                .foregroundStyle(.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.dislikeRed.opacity(0.10))
                    .frame(width: 100, height: 100)
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(.dislikeRed.opacity(0.7))
            }
            VStack(spacing: AppSpacing.xs) {
                Text("Something went wrong")
                    .font(AppFont.displaySmall())
                    .foregroundStyle(.textPrimary)
                Text(message)
                    .font(AppFont.bodySmall())
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            PrimaryButton("Try Again", icon: "arrow.clockwise", action: onRetry)
            Spacer()
        }
    }
}
