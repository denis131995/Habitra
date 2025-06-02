import SwiftUI

struct StatisticsView: View {
    let habits: [Habit]
    
    private var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.completionDates.count }
    }
    private var bestStreak: (habit: Habit, streak: Int)? {
        habits.map { ($0, $0.currentStreak) }.max { $0.1 < $1.1 }
    }
    private var mostCompleted: (habit: Habit, count: Int)? {
        habits.map { ($0, $0.completionDates.count) }.max { $0.1 < $1.1 }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Statistics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    HStack(spacing: 32) {
                        VStack {
                            Text("Total completions")
                                .font(.caption)
                            Text("\(totalCompletions)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        VStack {
                            Text("Total habits")
                                .font(.caption)
                            Text("\(habits.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top)
                    
                    if let best = bestStreak {
                        VStack {
                            Text("Best streak")
                                .font(.caption)
                            HStack {
                                Image(systemName: best.habit.icon)
                                    .foregroundColor(Color(hex: best.habit.colorHex) ?? .blue)
                                Text(best.habit.title)
                                Spacer()
                                Text("\(best.streak) days")
                                    .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    }
                    
                    if let most = mostCompleted {
                        VStack {
                            Text("Most frequent habit")
                                .font(.caption)
                            HStack {
                                Image(systemName: most.habit.icon)
                                    .foregroundColor(Color(hex: most.habit.colorHex) ?? .blue)
                                Text(most.habit.title)
                                Spacer()
                                Text("\(most.count) times")
                                    .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

extension Habit {
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = Date().stripTime
        let completionSet = Set(completionDates.map { $0.stripTime })
        var streak = 0
        var date = today
        while completionSet.contains(date) {
            streak += 1
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }
} 