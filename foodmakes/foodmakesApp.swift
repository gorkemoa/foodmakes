//
//  foodmakesApp.swift
//  foodmakes
//
//  Created by Görkem Öztürk  on 15.03.2026.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct foodmakesApp: App {

    let container: ModelContainer = {
        let schema = Schema([
            PersistedTryMeal.self,
            PersistedDislikedMeal.self,
            SwipedRecord.self,
            PersistedMealRating.self,
            PersistedMealPlan.self
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
                .task {
                    // Request notification permission once on first launch.
                    // If granted and user had a reminder enabled, reschedule it.
                    let granted = await NotificationManager.shared.requestPermission()
                    if granted && NotificationManager.shared.isEnabled {
                        NotificationManager.shared.scheduleDaily()
                    }
                }
        }
    }
}
