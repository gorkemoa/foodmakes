//
//  foodmakesApp.swift
//  foodmakes
//
//  Created by Görkem Öztürk  on 15.03.2026.
//

import SwiftUI
import SwiftData
import UserNotifications
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

@main
struct foodmakesApp: App {

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

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
                    // Request tracking authorization for App Store Guidelines 5.1.2(i)
                    if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                        // Small delay to ensure the app is in the active scene state
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        await ATTrackingManager.requestTrackingAuthorization()
                    }

                    // Increment launch counter and trigger rating prompt if needed
                    AppRatingService.shared.onAppLaunched()

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
