import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var habit: Habit
    let onSave: (Habit) -> Void
    
    @State private var title: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    @State private var selectedDays: Set<Weekday>
    @State private var reminderTime: Date?
    
    @FocusState private var isTitleFocused: Bool
    
    private let icons = [
        "star.fill", "heart.fill", "moon.fill", "sun.max.fill",
        "drop.fill", "flame.fill", "leaf.fill", "bolt.fill",
        "book.fill", "pencil", "paintbrush.fill", "music.note",
        "figure.walk", "bicycle", "bed.double.fill", "cup.and.saucer.fill"
    ]
    
    init(habit: Habit, onSave: @escaping (Habit) -> Void) {
        self._habit = State(initialValue: habit)
        self.onSave = onSave
        self._title = State(initialValue: habit.title)
        self._selectedIcon = State(initialValue: habit.icon)
        self._selectedColor = State(initialValue: Color(hex: habit.colorHex) ?? .blue)
        self._selectedDays = State(initialValue: Set(habit.frequency))
        self._reminderTime = State(initialValue: habit.reminderTime)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.blue.opacity(0.5)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Edit Habit")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                GlassSection {
                    VStack(spacing: 16) {
                        TextField("Habit Name", text: $title)
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .focused($isTitleFocused)
                        
                        VStack(alignment: .leading) {
                            Text("Icon")
                                .foregroundColor(.white.opacity(0.7))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(icons, id: \.self) { icon in
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundColor(selectedIcon == icon ? selectedColor : .gray)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                            )
                                            .onTapGesture {
                                                selectedIcon = icon
                                            }
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Text("Color")
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            ColorPicker("", selection: $selectedColor)
                                .labelsHidden()
                                .frame(width: 32, height: 32)
                        }
                    }
                }
                
                GlassSection {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Frequency")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                        HStack(spacing: 10) {
                            ForEach(Weekday.allCases) { day in
                                Button(action: {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedDays.contains(day) ? selectedColor : Color.white.opacity(0.08))
                                            .frame(width: 36, height: 36)
                                        Text(day.shortName)
                                            .font(.headline)
                                            .foregroundColor(selectedDays.contains(day) ? .white : .white.opacity(0.6))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                GlassSection {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reminder")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                        Toggle("Enable Reminder", isOn: Binding(
                            get: { reminderTime != nil },
                            set: { newValue in
                                if newValue {
                                    reminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())
                                } else {
                                    reminderTime = nil
                                }
                            }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: selectedColor))
                        .foregroundColor(.white)
                        if let time = reminderTime {
                            DatePicker("Time", selection: Binding(
                                get: { time },
                                set: { reminderTime = $0 }
                            ), displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: saveHabit) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [selectedColor, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: selectedColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                .disabled(title.isEmpty || selectedDays.isEmpty)
            }
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isTitleFocused = false }
            }
        }
    }
    
    private func saveHabit() {
        var updatedHabit = habit
        updatedHabit.title = title
        updatedHabit.icon = selectedIcon
        updatedHabit.colorHex = selectedColor.toHex() ?? "#0000FF"
        updatedHabit.frequency = Array(selectedDays)
        updatedHabit.reminderTime = reminderTime
        onSave(updatedHabit)
        dismiss()
    }
} 