import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for habit: Habit) {
        guard let reminderTime = habit.reminderTime else { return }
        let content = UNMutableNotificationContent()
        content.title = habit.title
        content.body = "Пора выполнить привычку!"
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        dateComponents.second = 0
        let id = habit.id.uuidString
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func removeNotification(for habit: Habit) {
        let id = habit.id.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
} 