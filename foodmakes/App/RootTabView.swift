import SwiftUI
import SwiftData
import Translation

// MARK: - Root Tab View
struct RootTabView: View {
    @State private var selectedTab = 0

    // Shared dependencies
    let repository: MealRepository
    let service = MealService()

    // Lazily created ViewModels  
    @State private var homeViewModel: HomeViewModel
    private var lm: LanguageManager { LanguageManager.shared }

    init(repository: MealRepository) {
        self.repository = repository
        _homeViewModel = State(initialValue: HomeViewModel(
            service: MealService(),
            repository: repository
        ))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label(lm.t.tabDiscover, systemImage: selectedTab == 0 ? "fork.knife.circle.fill" : "fork.knife.circle")
                }
                .tag(0)

            TryListView(repository: repository)
                .tabItem {
                    Label(lm.t.tabTryList, systemImage: selectedTab == 1 ? "heart.fill" : "heart")
                }
                .tag(1)

            DislikedView(repository: repository)
                .tabItem {
                    Label(lm.t.tabDisliked, systemImage: selectedTab == 2 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                }
                .tag(2)

            SettingsView(repository: repository)
                .tabItem {
                    Label(lm.t.tabSettings, systemImage: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                }
                .tag(3)
        }
        .tint(.warmOrange)
        // Single download dialog for the whole app — driven by TranslationDownloadManager
        .translationTask(TranslationDownloadManager.shared.pendingConfig) { _ in
            await MainActor.run { TranslationDownloadManager.shared.onDownloadCompleted() }
        }
    }
}
