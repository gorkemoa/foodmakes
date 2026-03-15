import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    private var lm: LanguageManager { LanguageManager.shared }

    init(repository: MealRepository) {
        _viewModel = State(initialValue: SettingsViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        appHeader
                        languageSection
                        dataManagementSection
                        aboutSection
                        Color.clear.frame(height: 60)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }

                // Toast
                if viewModel.showToast, let msg = viewModel.toastMessage {
                    toastBanner(msg)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(10)
                        .padding(.bottom, 28)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.showToast)
            .navigationTitle(lm.t.settingsTitle)
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - App Header Card
    private var appHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.warmOrange)
                    .frame(width: 52, height: 52)
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("FoodMakes")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Text(lm.t.appSubtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Language Picker Section
    private var languageSection: some View {
        SettingsSection(title: lm.t.language, icon: "globe") {
            VStack(spacing: 0) {
                ForEach(Array(AppLanguage.allCases.enumerated()), id: \.1.rawValue) { idx, lang in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            lm.current = lang
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Text(lang.flag)
                                .font(.system(size: 22))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(lang.displayName)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.textPrimary)
                                Text(lm.t.languageSub)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.textSecondary)
                                    .opacity(lm.current == lang ? 1 : 0)
                            }
                            Spacer()
                            if lm.current == lang {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.warmOrange)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if idx < AppLanguage.allCases.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Data Management Section
    private var dataManagementSection: some View {
        SettingsSection(title: lm.t.dataManagement, icon: "externaldrive.fill") {
            VStack(spacing: 0) {
                settingsRow(
                    icon: "heart.slash",
                    iconColor: .tryGreen,
                    title: lm.t.clearTryList,
                    subtitle: lm.t.clearTryListSub,
                    isDestructive: false
                ) { viewModel.showClearTryConfirm = true }

                divider

                settingsRow(
                    icon: "hand.thumbsdown.fill",
                    iconColor: .dislikeRed,
                    title: lm.t.clearDisliked,
                    subtitle: lm.t.clearDislikedSub,
                    isDestructive: false
                ) { viewModel.showClearDislikedConfirm = true }

                divider

                settingsRow(
                    icon: "clock.arrow.circlepath",
                    iconColor: .warmOrange,
                    title: lm.t.resetSwipeHistory,
                    subtitle: lm.t.resetSwipeHistorySub,
                    isDestructive: false
                ) { viewModel.showResetConfirm = true }

                divider

                settingsRow(
                    icon: "trash.fill",
                    iconColor: .red,
                    title: lm.t.resetEverything,
                    subtitle: lm.t.resetEverythingSub,
                    isDestructive: true
                ) { viewModel.showResetAllConfirm = true }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .confirmationDialog(lm.t.clearTryConfirm, isPresented: $viewModel.showClearTryConfirm, titleVisibility: .visible) {
            Button(lm.t.clearAll, role: .destructive) { viewModel.clearTryList() }
        }
        .confirmationDialog(lm.t.clearDislikedConfirm, isPresented: $viewModel.showClearDislikedConfirm, titleVisibility: .visible) {
            Button(lm.t.clearAll, role: .destructive) { viewModel.clearDisliked() }
        }
        .confirmationDialog(lm.t.resetSwipeConfirm, isPresented: $viewModel.showResetConfirm, titleVisibility: .visible) {
            Button(lm.t.resetHistory, role: .destructive) { viewModel.resetSwipeHistory() }
        }
        .confirmationDialog(lm.t.resetAllConfirm, isPresented: $viewModel.showResetAllConfirm, titleVisibility: .visible) {
            Button(lm.t.resetAllData, role: .destructive) { viewModel.resetAll() }
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        SettingsSection(title: lm.t.about, icon: "info.circle.fill") {
            VStack(spacing: 0) {
                HStack {
                    settingsIcon("number", color: .indigo)
                    Text(lm.t.version)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.horizontal, 16).padding(.vertical, 13)

                divider

                HStack {
                    settingsIcon("globe", color: .blue)
                    Text(lm.t.poweredBy)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Link("Visit →", destination: URL(string: "https://www.themealdb.com")!)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.warmOrange)
                }
                .padding(.horizontal, 16).padding(.vertical, 13)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Row Builder
    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isDestructive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                settingsIcon(icon, color: iconColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(isDestructive ? Color.red : Color.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func settingsIcon(_ name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(color)
                .frame(width: 34, height: 34)
            Image(systemName: name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
        }
    }

    private var divider: some View {
        Divider()
            .padding(.leading, 64)
    }

    // MARK: - Toast
    private func toastBanner(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.deepBrown.opacity(0.92))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.20), radius: 16, x: 0, y: 8)
    }
}

// MARK: - SettingsSection Wrapper
private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.warmOrange)
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                    .tracking(0.5)
            }
            .padding(.leading, 4)
            content()
        }
    }
}
