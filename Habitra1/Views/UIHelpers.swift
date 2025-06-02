import SwiftUI

struct GlassSection<Content: View>: View {
    let content: () -> Content
    var body: some View {
        content()
            .padding()
            .background(BlurView(style: .systemUltraThinMaterialDark))
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
            .padding(.vertical, 2)
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
} 