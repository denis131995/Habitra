import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Habitra")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    func addHabit(_ habit: Habit) {
        let context = container.viewContext
        let entity = HabitEntity(context: context)
        
        entity.id = habit.id
        entity.title = habit.title
        entity.icon = habit.icon
        entity.colorHex = habit.colorHex
        entity.frequency = habit.frequency.map { $0.rawValue }
        entity.completionDates = habit.completionDates
        entity.createdDate = habit.createdDate
        entity.setValue(habit.isArchived, forKey: "isArchived")
        entity.setValue(habit.reminderTime, forKey: "reminderTime")
        
        save()
        if habit.reminderTime != nil {
            NotificationManager.shared.scheduleNotification(for: habit)
        }
    }
    
    func updateHabit(_ habit: Habit) {
        let context = container.viewContext
        let request = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.title = habit.title
                entity.icon = habit.icon
                entity.colorHex = habit.colorHex
                entity.frequency = habit.frequency.map { $0.rawValue }
                entity.completionDates = habit.completionDates
                entity.setValue(habit.isArchived, forKey: "isArchived")
                entity.setValue(habit.reminderTime, forKey: "reminderTime")
                save()
                NotificationManager.shared.removeNotification(for: habit)
                if habit.reminderTime != nil {
                    NotificationManager.shared.scheduleNotification(for: habit)
                }
            }
        } catch {
            print("Error updating habit: \(error.localizedDescription)")
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        let context = container.viewContext
        let request = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                context.delete(entity)
                save()
                NotificationManager.shared.removeNotification(for: habit)
            }
        } catch {
            print("Error deleting habit: \(error.localizedDescription)")
        }
    }
    
    func archiveHabit(_ habit: Habit) {
        var updatedHabit = habit
        updatedHabit.isArchived = true
        updateHabit(updatedHabit)
    }
    
    func unarchiveHabit(_ habit: Habit) {
        var updatedHabit = habit
        updatedHabit.isArchived = false
        updateHabit(updatedHabit)
    }
    
    func fetchHabits(includeArchived: Bool = false) -> [Habit] {
        let context = container.viewContext
        let request = HabitEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            let allHabits = entities.map { Habit(entity: $0) }
            return includeArchived ? allHabits : allHabits.filter { !$0.isArchived }
        } catch {
            print("Error fetching habits: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAllHabits() {
        let context = container.viewContext
        let request = HabitEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            save()
        } catch {
            print("Error deleting all habits: \(error.localizedDescription)")
        }
    }
    
    func rescheduleAllHabitNotifications() {
        NotificationManager.shared.removeAllNotifications()
        let habits = fetchHabits(includeArchived: false)
        for habit in habits where habit.reminderTime != nil {
            NotificationManager.shared.scheduleNotification(for: habit)
        }
    }
} 