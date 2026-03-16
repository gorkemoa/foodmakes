import SwiftUI

struct TranslationInfoView: View {
    @Environment(\.dismiss) private var dismiss
    private var lm: LanguageManager { LanguageManager.shared }

    @State private var appear      = false
    @State private var stepsAppear = false

    // Demo animation states
    @State private var sheetY: CGFloat   = 210
    @State private var fingerOpacity: Double = 0
    @State private var fingerScale: CGFloat  = 1.0
    @State private var rippleScale: CGFloat  = 0.3
    @State private var rippleOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            // Pull handle
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 4)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // ── Interactive Demo ──
                    demoCard
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // ── Title & Desc ──
                    VStack(spacing: 8) {
                        Text(lm.t.translationInfoTitle)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 12)
                            .animation(.spring(response: 0.50, dampingFraction: 0.72).delay(0.10), value: appear)

                        Text(lm.t.translationInfoDesc)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(appear ? 1 : 0)
                            .animation(.spring(response: 0.50, dampingFraction: 0.72).delay(0.18), value: appear)
                    }

                    // ── 3 Feature Steps ──
                    VStack(spacing: 10) {
                        stepCard(icon: "icloud.and.arrow.down.fill", color: .blue,
                                 title: lm.t.translationInfoStep1Title,
                                 body:  lm.t.translationInfoStep1Body,  delay: 0.00)
                        stepCard(icon: "lock.shield.fill",            color: .green,
                                 title: lm.t.translationInfoStep2Title,
                                 body:  lm.t.translationInfoStep2Body,  delay: 0.10)
                        stepCard(icon: "bolt.fill",                   color: .orange,
                                 title: lm.t.translationInfoStep3Title,
                                 body:  lm.t.translationInfoStep3Body,  delay: 0.20)
                    }
                    .padding(.horizontal, 20)

                    // ── Dismiss ──
                    Button { dismiss() } label: {
                        Text(lm.t.translationInfoDismiss)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.warmOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .warmOrange.opacity(0.35), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .opacity(appear ? 1 : 0)
                    .scaleEffect(appear ? 1 : 0.9)
                    .animation(.spring(response: 0.55, dampingFraction: 0.70).delay(0.38), value: appear)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) { appear = true }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.25)) { stepsAppear = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { runCycle() }
        }
    }

    // MARK: - Demo Card
    // Shows a settings-like banner row, a finger tapping it, then a bottom sheet
    // rising from below — exactly what happens in-app.
    private var demoCard: some View {
        ZStack(alignment: .bottom) {
            // Card background
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.warmOrange.opacity(0.07), Color.blue.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 270)

            // ── Top content: fake settings rows ──
            VStack(spacing: 0) {
                // Label above the row
                HStack {
                    Text("LANGUAGE")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.secondary.opacity(0.6))
                        .kerning(0.8)
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 6)

                // The banner row being tapped
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.13))
                            .frame(width: 32, height: 32)
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.blue)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Capsule()
                            .fill(Color.primary.opacity(0.5))
                            .frame(width: 115, height: 7)
                        Capsule()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 75, height: 5)
                    }
                    Spacer()
                    Image(systemName: "chevron.up")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.blue.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 14)
                .scaleEffect(fingerScale)
                .animation(.spring(response: 0.18, dampingFraction: 0.5), value: fingerScale)
                // ripple circle
                .overlay(
                    Circle()
                        .stroke(Color.warmOrange.opacity(rippleOpacity), lineWidth: 1.8)
                        .frame(width: 48, height: 48)
                        .scaleEffect(rippleScale)
                        .animation(.easeOut(duration: 0.45), value: rippleScale)
                        .animation(.easeOut(duration: 0.45), value: rippleOpacity)
                )

                // Thin divider rows below
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { i in
                        HStack(spacing: 10) {
                            Text(["🇬🇧", "🇹🇷", "🇫🇷"][i])
                                .font(.system(size: 18))
                                .frame(width: 30, height: 30)
                            Capsule()
                                .fill(Color.primary.opacity(0.18))
                                .frame(width: CGFloat([60, 58, 56][i]), height: 6)
                            Spacer()
                            if i == 0 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.warmOrange)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        if i < 2 {
                            Divider().padding(.leading, 54)
                        }
                    }
                }
                .padding(.top, 4)

                Spacer()
            }
            .frame(height: 270)
            .clipped()

            // Finger pointer
            Image(systemName: "hand.point.up.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.warmOrange)
                .rotationEffect(.degrees(180))
                .offset(x: 30, y: -196)
                .opacity(fingerOpacity)
                .animation(.easeInOut(duration: 0.22), value: fingerOpacity)

            // ── Rising bottom sheet ──
            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.secondary.opacity(0.38))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)

                // Flag pills row
                HStack(spacing: 8) {
                    ForEach(["🇬🇧", "🇹🇷", "🇫🇷", "🇪🇸", "🇮🇹"], id: \.self) { flag in
                        Text(flag)
                            .font(.system(size: 18))
                            .frame(width: 36, height: 36)
                            .background(Color(.systemBackground).opacity(0.85))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.07), radius: 4, y: 2)
                    }
                }
                .padding(.top, 12)

                // Content lines
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 7)
                                .fill([Color.blue, Color.green, Color.orange][i].opacity(0.18))
                                .frame(width: 30, height: 30)
                            VStack(alignment: .leading, spacing: 4) {
                                Capsule()
                                    .fill(Color.primary.opacity(0.4))
                                    .frame(width: CGFloat([110, 90, 100][i]), height: 6)
                                Capsule()
                                    .fill(Color.secondary.opacity(0.18))
                                    .frame(width: CGFloat([75, 62, 70][i]), height: 4)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                    }
                }
                .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.16), radius: 18, y: -6)
            .offset(y: sheetY)
            .animation(.spring(response: 0.50, dampingFraction: 0.76), value: sheetY)
            // Clip to card bounds
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .opacity(appear ? 1 : 0)
        .animation(.easeIn(duration: 0.3).delay(0.05), value: appear)
    }

    // MARK: - Step card
    private func stepCard(icon: String, color: Color, title: String, body: String, delay: Double) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 15, weight: .bold))
                Text(body)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .opacity(stepsAppear ? 1 : 0)
        .offset(x: stepsAppear ? 0 : 24)
        .animation(.spring(response: 0.50, dampingFraction: 0.72).delay(delay + 0.08), value: stepsAppear)
    }

    // MARK: - Animation cycle
    // finger appears → taps (scale + ripple) → sheet rises → sheet falls → repeat
    private func runCycle() {
        // 1. Finger appears
        withAnimation { fingerOpacity = 1 }
        // 2. Tap press
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            fingerScale  = 0.93
            rippleScale  = 1.5
            rippleOpacity = 0.85
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        // 3. Release
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            fingerScale   = 1.0
            rippleOpacity = 0
        }
        // 4. Sheet rises + finger hides
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { fingerOpacity = 0 }
            sheetY = 0
        }
        // 5. Sheet falls
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            sheetY = 210
        }
        // 6. Repeat
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.4) {
            runCycle()
        }
    }
}

#Preview {
    TranslationInfoView()
}


