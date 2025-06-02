import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var page = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue, Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $page) {
                VStack(spacing: 32) {
                    Spacer()
                    Image(systemName: "sparkles")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    Text("Welcome to Habitra!")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Build healthy habits with a beautiful and smart tracker.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .tag(0)
                
                VStack(spacing: 32) {
                    Spacer()
                    Image(systemName: "paintpalette.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    Text("Customizable Habits")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Choose icons, colors, set reminders, and track your progress.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .tag(1)
                
                VStack(spacing: 32) {
                    Spacer()
                    Image(systemName: "chart.bar.xaxis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    Text("Stay Motivated")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Get daily quotes, see your streaks, and view detailed statistics.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button(action: {
                        hasSeenOnboarding = true
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(16)
                            .shadow(radius: 8)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
} 