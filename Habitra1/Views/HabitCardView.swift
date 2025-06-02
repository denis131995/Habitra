import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let onToggle: (Date) -> Void
    
    private var color: Color {
        Color(hex: habit.colorHex) ?? .blue
    }
    
    var body: some View {
        GlassCard(accent: color) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)
                            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                        Image(systemName: habit.icon)
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Text(habit.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    let today = Date().stripTime
                    let isDoneToday = habit.completionDates.contains(where: { $0.stripTime == today })
                    Button(action: {
                        onToggle(today)
                    }) {
                        HStack {
                            Image(systemName: isDoneToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isDoneToday ? .green : .gray)
                                .font(.title2)
                            Text("Done")
                                .foregroundColor(isDoneToday ? .green : .white)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            BlurView(style: .systemMaterial)
                                .clipShape(Capsule())
                        )
                        .overlay(
                            Capsule().stroke(isDoneToday ? Color.green : Color.white.opacity(0.2), lineWidth: 2)
                        )
                        .shadow(color: isDoneToday ? .green.opacity(0.2) : .clear, radius: 8, x: 0, y: 2)
                        .animation(.spring(), value: isDoneToday)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(Weekday.allCases) { day in
                        Circle()
                            .fill(habit.frequency.contains(day) ? color.opacity(0.3) : Color.white.opacity(0.08))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(day.shortName)
                                    .font(.caption2)
                                    .foregroundColor(habit.frequency.contains(day) ? color : .white.opacity(0.5))
                            )
                            .onTapGesture {
                                if habit.frequency.contains(day) {
                                    onToggle(Date())
                                }
                            }
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            .sRGB,
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0,
            opacity: 1.0
        )
    }
} 