import SwiftUI

struct ThemeOnboardingView: View {
    @State private var selected: AppThemePreference? = nil
    @State private var animateIn = false
    private var lm: LanguageManager { LanguageManager.shared }

    let onContinue: (AppThemePreference) -> Void

    // Soft dark: not pitch black — graphite/charcoal
    private let darkBg     = Color(red: 0.13, green: 0.13, blue: 0.16)
    private let darkSurface = Color(red: 0.18, green: 0.18, blue: 0.22)
    private let darkCard   = Color(red: 0.22, green: 0.22, blue: 0.27)

    var body: some View {
        ZStack {
            // Background preview — smooth transition
            Group {
                if selected == .dark {
                    darkBg.ignoresSafeArea()
                } else {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                }
            }
            .animation(.easeInOut(duration: 0.45), value: selected)

            VStack(spacing: 0) {
                Spacer()

                // App icon
                Image("AppLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                    .padding(.bottom, 28)
                    .scaleEffect(animateIn ? 1 : 0.6)
                    .opacity(animateIn ? 1 : 0)

                Text(lm.t.themeOnboardingTitle)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(selected == .dark ? .white : Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                Text(lm.t.themeOnboardingSubtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(selected == .dark ? Color(white: 0.65) : Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 44)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                // Theme cards
                HStack(spacing: 16) {
                    themeCard(.light,
                              icon: "sun.max.fill",
                              iconColor: Color(red: 0.95, green: 0.65, blue: 0.10),
                              label: lm.t.themeLight,
                              recommended: true)

                    themeCard(.dark,
                              icon: "moon.fill",
                              iconColor: Color(red: 0.55, green: 0.55, blue: 0.95),
                              label: lm.t.themeDark,
                              recommended: false)
                }
                .padding(.horizontal, 24)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 30)

                Spacer()

                // Continue button
                Button {
                    onContinue(selected ?? .system)
                } label: {
                    Text(lm.t.themeContinue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selected != nil
                                ? Color.warmOrange
                                : Color.warmOrange.opacity(0.40)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .animation(.easeInOut(duration: 0.2), value: selected)
                }
                .disabled(selected == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(animateIn ? 1 : 0)

                Text(lm.t.themeChangeHint)
                    .font(.system(size: 12))
                    .foregroundStyle(selected == .dark ? Color(white: 0.5) : Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 36)
                    .opacity(animateIn ? 1 : 0)
            }
        }
        .preferredColorScheme(selected?.colorScheme)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                animateIn = true
            }
        }
    }

    @ViewBuilder
    private func themeCard(
        _ theme: AppThemePreference,
        icon: String,
        iconColor: Color,
        label: String,
        recommended: Bool
    ) -> some View {
        let isSelected  = selected == theme
        let isDarkMode  = selected == .dark

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selected = theme
            }
        } label: {
            VStack(spacing: 0) {
                // Mini UI preview panel
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(theme == .dark ? darkCard : Color(.systemBackground))
                        .frame(height: 96)

                    VStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(isSelected ? Color.warmOrange : iconColor)

                        // Fake menu bars to preview the UI feel
                        VStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(theme == .dark
                                      ? Color(white: 0.45)
                                      : Color(white: 0.80))
                                .frame(width: 56, height: 5)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(theme == .dark
                                      ? Color(white: 0.35)
                                      : Color(white: 0.88))
                                .frame(width: 40, height: 4)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 14)

                Spacer().frame(height: 12)

                // Label + recommended badge
                VStack(spacing: 5) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isDarkMode ? .white : Color.textPrimary)

                    if recommended {
                        Text(lm.t.themeRecommended)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.warmOrange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.warmOrange.opacity(0.12))
                            .clipShape(Capsule())
                    } else {
                        // Keep height consistent
                        Color.clear.frame(height: 20)
                    }
                }
                .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isDarkMode ? darkSurface : Color(.secondarySystemBackground))
                    .shadow(color: isSelected ? Color.warmOrange.opacity(0.22) : Color.black.opacity(0.06),
                            radius: isSelected ? 14 : 6, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(isSelected ? Color.warmOrange : Color.clear, lineWidth: 2.5)
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
