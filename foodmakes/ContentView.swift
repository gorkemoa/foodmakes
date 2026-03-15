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

    var body: some View {
        RootTabView(repository: MealRepository(context: modelContext))
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
