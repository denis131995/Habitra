import SwiftUI
import SafariServices

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var showingResetAlert = false
    var onReset: (() -> Void)? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { enabled in
                            if enabled {
                                CoreDataManager.shared.rescheduleAllHabitNotifications()
                            } else {
                                NotificationManager.shared.removeAllNotifications()
                            }
                        }
                }
                
                Section {
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/app/id123456789") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Rate App")
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://your-privacy-policy-url.com") {
                            let safariVC = SFSafariViewController(url: url)
                            UIApplication.shared.windows.first?.rootViewController?.present(safariVC, animated: true)
                        }
                    }) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Text("Reset All Data")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    CoreDataManager.shared.deleteAllHabits()
                    onReset?()
                }
            } message: {
                Text("Are you sure you want to delete all your habits? This action cannot be undone.")
            }
        }
    }
} 