import SwiftUI

struct HabitHistoryView: View {
    let habit: Habit
    var onEdit: ((Habit) -> Void)? = nil
    var onDelete: ((Habit) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false
    
    private var completionSet: Set<Date> {
        Set(habit.completionDates.map { $0.stripTime })
    }
    
    private var calendar: Calendar { Calendar.current }
    private var today: Date { Date().stripTime }
    private var startDate: Date {
        calendar.date(byAdding: .month, value: -2, to: today) ?? today
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(habit.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                CalendarGridView(
                    startDate: startDate,
                    endDate: today,
                    completionSet: completionSet,
                    accentColor: Color(hex: habit.colorHex) ?? .blue
                )
                
                Text("Streak: \(calculateStreak()) дней подряд")
                    .font(.headline)
                    .padding(.top)
                
                Spacer()
            }
            .navigationTitle("История")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showEdit = true }) {
                            Image(systemName: "pencil")
                        }
                        Button(action: { showDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEdit) {
                EditHabitView(habit: habit) { updatedHabit in
                    onEdit?(updatedHabit)
                    dismiss()
                }
            }
            .alert("Delete Habit", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    onDelete?(habit)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this habit?")
            }
        }
    }
    
    private func calculateStreak() -> Int {
        var streak = 0
        var date = today
        while completionSet.contains(date) {
            streak += 1
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }
}

struct CalendarGridView: View {
    let startDate: Date
    let endDate: Date
    let completionSet: Set<Date>
    let accentColor: Color
    
    private var calendar: Calendar { Calendar.current }
    private var days: [Date] {
        var days: [Date] = []
        var date = startDate
        while date <= endDate {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return days
    }
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { date in
                Circle()
                    .fill(completionSet.contains(date) ? accentColor : Color.gray.opacity(0.15))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("\(calendar.component(.day, from: date))")
                            .font(.caption2)
                            .foregroundColor(completionSet.contains(date) ? .white : .gray)
                    )
            }
        }
        .padding(.horizontal)
    }
}

extension Date {
    var stripTime: Date {
        Calendar.current.startOfDay(for: self)
    }
} 