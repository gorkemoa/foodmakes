//
//  ContentView.swift
//  foodmakes
//
//  Created by Görkem Öztürk  on 15.03.2026.
//

import SwiftUI
import SwiftData

// AppRootView wires the ModelContext into MealRepository and boots the tab bar
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    private var themeManager: ThemeManager { ThemeManager.shared }

    var body: some View {
        Group {
            if !themeManager.onboardingDone {
                ThemeOnboardingView { chosen in
                    themeManager.preference = chosen
                    themeManager.onboardingDone = true
                }
            } else if !themeManager.showcaseDone {
                OnboardingView {
                    themeManager.showcaseDone = true
                }
            } else {
                RootTabView(repository: MealRepository(context: modelContext))
            }
        }
        .preferredColorScheme(themeManager.preference.colorScheme)
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [
            PersistedTryMeal.self,
            PersistedDislikedMeal.self,
            SwipedRecord.self
        ], inMemory: true)
}
