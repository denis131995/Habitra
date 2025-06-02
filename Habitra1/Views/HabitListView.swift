import SwiftUI

struct HabitListView: View {
    @State private var habits: [Habit] = []
    @State private var archivedHabits: [Habit] = []
    @State private var showingAddHabit = false
    @State private var showingSettings = false
    @State private var editingHabit: Habit? = nil
    @State private var showingHistoryHabit: Habit? = nil
    @State private var showingStatistics = false
    
    private let userName = "User" // In a real app, this would come from user settings
    private let quotes = [
        "Big changes start with small steps.",
        "Today is the best day to start!",
        "Habits shape your future.",
        "Make every day a little better than yesterday.",
        "Success is the repetition of simple actions every day.",
        "Strength is in consistency!",
        "You can do more than you think."
    ]
    private let facts = [
        "It takes an average of 21 days to form a new habit.",
        "People who track their habits achieve goals 40% more often.",
        "The brain uses less energy for habits than for new actions.",
        "Writing down goals increases the chance of achieving them by 42%.",
        "Small daily actions lead to big results.",
        "Habits are automatic decisions that save brain energy.",
        "Positive habits improve mood and productivity."
    ]
    @State private var quote: String = ""
    @State private var isFact: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                Color(.black).opacity(0.7).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Good Morning, \(userName)")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        QuoteFactCard(isFact: isFact, text: quote)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        if !habits.isEmpty {
                            LazyVStack(spacing: 16) {
                                ForEach(habits) { habit in
                                    Button(action: { showingHistoryHabit = habit }) {
                                        HabitCardView(habit: habit) { date in
                                            toggleHabit(habit, date: date)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Button("Редактировать") { editingHabit = habit }
                                        Button("Архивировать") { archiveHabit(habit) }
                                        Button("Удалить", role: .destructive) { deleteHabit(habit) }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Text("No habits. Add your first one!")
                                .foregroundColor(.secondary)
                        }
                        
                        if !archivedHabits.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Архивированные")
                                    .font(.headline)
                                    .padding(.top)
                                ForEach(archivedHabits) { habit in
                                    HabitCardView(habit: habit) { _ in }
                                        .opacity(0.5)
                                        .contextMenu {
                                            Button("Восстановить") { unarchiveHabit(habit) }
                                            Button("Удалить", role: .destructive) { deleteHabit(habit) }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddHabit = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingStatistics = true }) {
                        Image(systemName: "chart.bar.xaxis")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView { newHabit in
                    addHabit(newHabit)
                }
            }
            .sheet(item: $editingHabit) { habit in
                EditHabitView(habit: habit) { updatedHabit in
                    updateHabit(updatedHabit)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(onReset: {
                    loadHabits()
                })
            }
            .sheet(item: $showingHistoryHabit) { habit in
                HabitHistoryView(habit: habit,
                    onEdit: { updatedHabit in
                        updateHabit(updatedHabit)
                    },
                    onDelete: { habitToDelete in
                        deleteHabit(habitToDelete)
                    }
                )
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView(habits: habits + archivedHabits)
            }
        }
        .onAppear {
            loadHabits()
            let showFact = Bool.random()
            isFact = showFact
            if showFact {
                quote = facts.randomElement() ?? "Интересный факт!"
            } else {
                quote = quotes.randomElement() ?? "Верь в себя!"
            }
        }
    }
    
    private func loadHabits() {
        let allHabits = CoreDataManager.shared.fetchHabits(includeArchived: true)
        habits = allHabits.filter { !$0.isArchived }
        archivedHabits = allHabits.filter { $0.isArchived }
    }
    
    private func addHabit(_ habit: Habit) {
        CoreDataManager.shared.addHabit(habit)
        loadHabits()
    }
    
    private func updateHabit(_ habit: Habit) {
        CoreDataManager.shared.updateHabit(habit)
        loadHabits()
    }
    
    private func toggleHabit(_ habit: Habit, date: Date) {
        var updatedHabit = habit
        if updatedHabit.completionDates.contains(date) {
            updatedHabit.completionDates.removeAll { $0 == date }
        } else {
            updatedHabit.completionDates.append(date)
        }
        CoreDataManager.shared.updateHabit(updatedHabit)
        loadHabits()
    }
    
    private func archiveHabit(_ habit: Habit) {
        CoreDataManager.shared.archiveHabit(habit)
        loadHabits()
    }
    
    private func unarchiveHabit(_ habit: Habit) {
        CoreDataManager.shared.unarchiveHabit(habit)
        loadHabits()
    }
    
    private func deleteHabit(_ habit: Habit) {
        CoreDataManager.shared.deleteHabit(habit)
        loadHabits()
    }
}

struct AnimatedBackground: View {
    @State private var animate = false
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.purple.opacity(0.7),
                Color.blue.opacity(0.7),
                Color.cyan.opacity(0.7),
                Color.pink.opacity(0.7)
            ]),
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .hueRotation(.degrees(animate ? 20 : -20))
        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
    }
}

struct GlassCard<Content: View>: View {
    let accent: Color
    let content: () -> Content
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(accent)
                .frame(width: 6)
                .cornerRadius(3)
                .shadow(color: accent.opacity(0.3), radius: 6, x: 0, y: 0)
            content()
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    BlurView(style: .systemUltraThinMaterialDark)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                )
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: accent.opacity(0.18), radius: 10, x: 0, y: 6)
    }
}

struct QuoteFactCard: View {
    let isFact: Bool
    let text: String
    @State private var appear = false
    
    var body: some View {
        GlassCard(accent: isFact ? .yellow : .blue) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: isFact ? "lightbulb.fill" : "quote.bubble.fill")
                        .foregroundColor(isFact ? .yellow : .blue)
                    Text(isFact ? "Fact of the Day" : "Quote of the Day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(text)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.top, 2)
            }
        }
    }
} 