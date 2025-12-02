import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct GeometricMiniLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var angle: Double = 0
    @State private var glow: Bool = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Animated gradient background (no images)
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0F2027"),
                        Color(hex: "#203A43"),
                        Color(hex: "#2C5364"),
                        Color(hex: "#0F2027"),
                    ]),
                    center: .center,
                    angle: .degrees(angle)
                )
                .ignoresSafeArea()
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: angle)
                .onAppear { angle = 360 }

                VStack(spacing: 28) {
                    // Circular spinner
                    GeometricMiniCircularSpinner(progress: progress)
                        .frame(width: min(geo.size.width, geo.size.height) * 0.32,
                               height: min(geo.size.width, geo.size.height) * 0.32)
                        .shadow(color: Color.white.opacity(glow ? 0.35 : 0.1), radius: glow ? 24 : 8)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glow)
                        .onAppear { glow = true }

                    // English text only
                    VStack(spacing: 8) {
                        Text("Loading...")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 1)

                        Text("\(progressPercentage)%")
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.08)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 1
                            )
                    )
                    .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - Фоновые представления

struct GeometricMiniBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#0B0F1A"),
                Color(hex: "#0F172A"),
                Color(hex: "#111827"),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Circular Spinner

private struct GeometricMiniCircularSpinner: View {
    let progress: Double
    @State private var rotation: Double = 0
    @State private var reverseRotation: Double = 0
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 12)

            // Progress ring
            Circle()
                .trim(from: 0, to: max(0.02, min(1.0, progress)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#22D3EE"), // cyan
                            Color(hex: "#38BDF8"), // sky
                            Color(hex: "#6366F1"), // indigo
                            Color(hex: "#A855F7"), // purple
                            Color(hex: "#F472B6"), // pink
                        ]),
                        center: .center,
                        angle: .degrees(rotation)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color(hex: "#22D3EE").opacity(0.35), radius: 10)
                .animation(.easeInOut(duration: 0.25), value: progress)

            // Counter-rotating dashed inner ring
            Circle()
                .inset(by: 14)
                .trim(from: 0, to: 1)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [1, 8])
                )
                .rotationEffect(.degrees(reverseRotation))
                .animation(.linear(duration: 3.0).repeatForever(autoreverses: false), value: reverseRotation)

            // Orbiting highlight dot
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .shadow(color: Color.white.opacity(0.6), radius: 6)
                .offset(x: pulse ? 72 : 68)
                .rotationEffect(.degrees(rotation))
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                reverseRotation = -360
            }
            pulse = true
        }
    }
}

// MARK: - Previews

#if canImport(SwiftUI)
import SwiftUI
#endif

// Use availability to keep using the modern #Preview API on iOS 17+ and provide a fallback for older versions
@available(iOS 17.0, *)
#Preview("Vertical") {
    GeometricMiniLoadingOverlay(progress: 0.2)
}

@available(iOS 17.0, *)
#Preview("Horizontal", traits: .landscapeRight) {
    GeometricMiniLoadingOverlay(progress: 0.2)
}

// Fallback previews for iOS < 17
struct GeometricMiniLoadingOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeometricMiniLoadingOverlay(progress: 0.2)
                .previewDisplayName("Vertical (Legacy)")

            GeometricMiniLoadingOverlay(progress: 0.2)
                .previewDisplayName("Horizontal (Legacy)")
                .previewLayout(.fixed(width: 812, height: 375)) // Simulate landscape on older previews
        }
    }
}
