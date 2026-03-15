//
//  foodmakesApp.swift
//  foodmakes
//
//  Created by Görkem Öztürk  on 15.03.2026.
//

import SwiftUI
import SwiftData

@main
struct foodmakesApp: App {

    let container: ModelContainer = {
        let schema = Schema([
            PersistedTryMeal.self,
            PersistedDislikedMeal.self,
            SwipedRecord.self,
            PersistedMealRating.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("SwiftData container could not be created: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(container)
        }
    }
}
