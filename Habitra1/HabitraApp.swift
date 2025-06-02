import SwiftUI

@main
struct HabitraApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HabitListView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            } else {
                OnboardingView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
    }
} 