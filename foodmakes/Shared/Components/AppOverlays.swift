import SwiftUI
import StoreKit

// MARK: - App Rating Prompt Overlay
struct AppRatingPromptView: View {
    @Environment(\.requestReview) private var requestReview
    private var lm: LanguageManager { LanguageManager.shared }
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                // App icon
                Image("AppLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
                    .padding(.bottom, 18)

                Text(lm.t.rateAppPopupTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                Text(lm.t.rateAppPopupMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)

                // Star decoration
                HStack(spacing: 8) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.warmOrange)
                    }
                }
                .padding(.bottom, 24)

                // Buttons
                HStack(spacing: 12) {
                    Button(lm.t.notNow) {
                        onDismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button(lm.t.rateNow) {
                        requestReview()
                        onDismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.warmOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(26)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 10)
            .padding(.horizontal, 28)
        }
    }
}

// MARK: - App Update Alert Overlay
struct AppUpdateAlertView: View {
    let currentVersion: String
    let latestVersion: String
    let onUpdate: () -> Void
    let onLater: () -> Void
    private var lm: LanguageManager { LanguageManager.shared }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.warmOrange.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.warmOrange)
                }
                .padding(.bottom, 16)

                Text(lm.t.updateAvailableTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.bottom, 8)

                Text(String(format: lm.t.updateAvailableMessage, latestVersion))
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)

                Text(String(format: lm.t.updateCurrentVersion, currentVersion))
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .padding(.bottom, 24)

                // Buttons
                HStack(spacing: 12) {
                    Button(lm.t.updateLater) {
                        onLater()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button(lm.t.updateNow) {
                        onUpdate()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.warmOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(26)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 10)
            .padding(.horizontal, 28)
        }
    }
}
