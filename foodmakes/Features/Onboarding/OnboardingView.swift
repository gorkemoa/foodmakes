import SwiftUI

// MARK: - Onboarding View (Elite Animated Showcase)

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isTransitioning: Bool = false

    // Transition states
    @State private var slideInOffset: CGFloat = 0
    @State private var slideOutOffset: CGFloat = 0
    @State private var contentOpacity: Double = 1

    private var lm: LanguageManager { LanguageManager.shared }

    var body: some View {
        ZStack {
            // Full-screen animated background
            OnboardBackground(index: currentIndex)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar.padding(.top, 16).padding(.horizontal, 28)
                Spacer(minLength: 0)
                slideContent
                Spacer(minLength: 0)
                bottomBar.padding(.horizontal, 24).padding(.bottom, 52)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    guard !isTransitioning else { return }
                    if value.translation.width < -60, currentIndex < 4 { go(to: currentIndex + 1) }
                    else if value.translation.width > 60, currentIndex > 0 { go(to: currentIndex - 1) }
                }
        )
    }

    // MARK: — Top Bar
    private var topBar: some View {
        HStack {
            Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { onFinish() } } label: {
                Text(lm.t.onboardSkip)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .opacity(currentIndex == 4 ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<5) { i in
                    Capsule()
                        .fill(i == currentIndex ? Color.white : Color.white.opacity(0.35))
                        .frame(width: i == currentIndex ? 24 : 7, height: 7)
                        .animation(.spring(response: 0.45, dampingFraction: 0.7), value: currentIndex)
                }
            }

            Spacer()

            // Mirror for balance
            Text(lm.t.onboardSkip)
                .font(.system(size: 14, weight: .semibold))
                .opacity(0)
                .padding(.horizontal, 14).padding(.vertical, 7)
        }
    }

    // MARK: — Slide Content
    @ViewBuilder
    private var slideContent: some View {
        ZStack {
            switch currentIndex {
            case 0: Slide0View()
            case 1: Slide1View()
            case 2: Slide2View()
            case 3: Slide3View()
            case 4: Slide4View()
            default: EmptyView()
            }
        }
        .offset(x: slideInOffset)
        .opacity(contentOpacity)
        .padding(.bottom, 8)
    }

    // MARK: — Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            // Title + Subtitle
            VStack(spacing: 10) {
                Text(slideTitle)
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                    .id("title-\(currentIndex)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                Text(slideSubtitle)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(3)
                    .id("sub-\(currentIndex)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
            .padding(.horizontal, 8)
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: currentIndex)
            .padding(.bottom, 28)

            // CTA Button
            Button {
                if currentIndex == 4 { 
                    onFinish() 
                }
                else { go(to: currentIndex + 1) }
            } label: {
                HStack(spacing: 8) {
                    Text(currentIndex == 4 ? lm.t.onboardGetStarted : lm.t.onboardNext)
                        .font(.system(size: 17, weight: .bold))
                    Image(systemName: currentIndex == 4 ? "checkmark" : "arrow.right")
                        .font(.system(size: 14, weight: .black))
                }
                .foregroundStyle(slideAccentColor)
                .frame(maxWidth: .infinity).frame(height: 60)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
            }
        }
    }

    // MARK: — Helpers
    private var slideTitle: String {
        switch currentIndex {
        case 0: return lm.t.onboardSlide1Title
        case 1: return lm.t.onboardSlide2Title
        case 2: return lm.t.onboardSlide3Title
        case 3: return lm.t.onboardSlide4Title
        default: return lm.t.onboardSlide5Title
        }
    }
    private var slideSubtitle: String {
        switch currentIndex {
        case 0: return lm.t.onboardSlide1Sub
        case 1: return lm.t.onboardSlide2Sub
        case 2: return lm.t.onboardSlide3Sub
        case 3: return lm.t.onboardSlide4Sub
        default: return lm.t.onboardSlide5Sub
        }
    }
    private var slideAccentColor: Color {
        switch currentIndex {
        case 0: return Color(red: 0.82, green: 0.33, blue: 0.19)
        case 1: return Color(red: 0.17, green: 0.75, blue: 0.42)
        case 2: return Color(red: 0.92, green: 0.20, blue: 0.22)
        case 3: return Color(red: 0.32, green: 0.46, blue: 0.96)
        default: return Color(red: 0.78, green: 0.59, blue: 0.18)
        }
    }

    private func go(to index: Int) {
        guard !isTransitioning else { return }
        isTransitioning = true
        let forward = index > currentIndex
        withAnimation(.easeIn(duration: 0.18)) {
            slideInOffset = forward ? -UIScreen.main.bounds.width * 0.3 : UIScreen.main.bounds.width * 0.3
            contentOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentIndex = index
            slideInOffset = forward ? UIScreen.main.bounds.width * 0.4 : -UIScreen.main.bounds.width * 0.4
            withAnimation(.spring(response: 0.48, dampingFraction: 0.78)) {
                slideInOffset = 0
                contentOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isTransitioning = false }
        }
    }
}

// MARK: ─ Animated Background ────────────────────────────────────────────────

private struct OnboardBackground: View {
    let index: Int
    @State private var phase: CGFloat = 0

    private let configs: [(top: Color, bottom: Color)] = [
        (Color(red: 0.88, green: 0.38, blue: 0.20), Color(red: 0.20, green: 0.10, blue: 0.06)),
        (Color(red: 0.12, green: 0.68, blue: 0.38), Color(red: 0.05, green: 0.22, blue: 0.13)),
        (Color(red: 0.90, green: 0.18, blue: 0.18), Color(red: 0.22, green: 0.06, blue: 0.06)),
        (Color(red: 0.30, green: 0.44, blue: 0.95), Color(red: 0.08, green: 0.10, blue: 0.30)),
        (Color(red: 0.80, green: 0.60, blue: 0.14), Color(red: 0.20, green: 0.14, blue: 0.04))
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [configs[index].top, configs[index].bottom],
                startPoint: .top, endPoint: .bottom
            )
            .animation(.easeInOut(duration: 0.55), value: index)

            // Breathing glow orb — top
            Ellipse()
                .fill(configs[index].top.opacity(0.45))
                .frame(width: 380, height: 300)
                .blur(radius: 90)
                .offset(x: 60 + sin(phase) * 20, y: -180 + cos(phase * 0.7) * 18)
                .animation(.easeInOut(duration: 0.55), value: index)

            // Breathing glow orb — bottom
            Ellipse()
                .fill(configs[index].bottom.opacity(0.6))
                .frame(width: 300, height: 260)
                .blur(radius: 80)
                .offset(x: -80 + cos(phase * 0.8) * 16, y: 260 + sin(phase) * 14)
                .animation(.easeInOut(duration: 0.55), value: index)
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: ─ Slide 0 · Discover Meals ───────────────────────────────────────────

private struct Slide0View: View {
    @State private var appear = false
    @State private var float0: CGFloat = 0
    @State private var float1: CGFloat = 0
    @State private var float2: CGFloat = 0
    @State private var float3: CGFloat = 0
    @State private var rotate: Double = 0
    @State private var pulse: CGFloat = 1

    private let foods = [("🍕", -100.0, -60.0), ("🍜", 100.0, -40.0), ("🥗", -110.0, 50.0), ("🍣", 110.0, 70.0)]

    var body: some View {
        ZStack {
            // Outer spin ring
            Circle()
                .strokeBorder(.white.opacity(0.12), lineWidth: 1.5)
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(rotate))
                .scaleEffect(appear ? 1 : 0.5)

            // Pulsing glow
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 190, height: 190)
                .scaleEffect(pulse)

            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 140, height: 140)
                .scaleEffect(appear ? 1 : 0.3)

            // Main icon
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .scaleEffect(appear ? 1 : 0.2)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)

            // Floating food emoji
            ForEach(Array(foods.enumerated()), id: \.offset) { i, food in
                let floats: [CGFloat] = [float0, float1, float2, float3]
                Text(food.0)
                    .font(.system(size: 30))
                    .offset(x: food.1, y: food.2 + floats[i])
                    .scaleEffect(appear ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1 + Double(i) * 0.09), value: appear)
            }
        }
        .frame(height: 320)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) { appear = true }
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) { rotate = 360 }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { pulse = 1.12 }
            // Independent floats
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.0)) { float0 = -12 }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.3)) { float1 = 10 }
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true).delay(0.6)) { float2 = -8 }
            withAnimation(.easeInOut(duration: 2.3).repeatForever(autoreverses: true).delay(0.9)) { float3 = 14 }
        }
    }
}

// MARK: ─ Slide 1 · Swipe Right ──────────────────────────────────────────────

private struct Slide1View: View {
    @State private var appear = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var stampOpacity: Double = 0
    @State private var stampScale: CGFloat = 0.4
    @State private var nextCardScale: CGFloat = 0.92
    @State private var arrowPhase: Int = 0

    var body: some View {
        ZStack {
            // Background card (next meal)
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.12))
                .frame(width: 220, height: 290)
                .scaleEffect(nextCardScale)
                .offset(y: 8)

            // Main swipeable card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    )

                VStack(spacing: 12) {
                    Text("🥘")
                        .font(.system(size: 64))
                    Text("Chicken Tagine")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Moroccan · 45 min")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.65))
                }

                // TRY stamp
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(red: 0.17, green: 0.80, blue: 0.44), lineWidth: 3)
                        .frame(width: 90, height: 38)
                    Text("TRY ✓")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color(red: 0.17, green: 0.80, blue: 0.44))
                }
                .rotationEffect(.degrees(-18))
                .offset(x: -48, y: -80)
                .opacity(stampOpacity)
                .scaleEffect(stampScale)
            }
            .frame(width: 220, height: 290)
            .rotationEffect(.degrees(cardRotation))
            .offset(x: cardOffset)
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 12)

            // Animated arrows — right side
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    HStack(spacing: -4) {
                        ForEach(0..<3) { i in
                            Image(systemName: "chevron.right")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white.opacity(arrowPhase > i ? 0.9 : 0.2))
                                .animation(.easeInOut(duration: 0.25).delay(Double(i) * 0.08), value: arrowPhase)
                        }
                    }
                    Text("swipe")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 4)
                }
                .padding(.trailing, 8)
            }
            .frame(width: 300)
        }
        .frame(height: 340)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { appear = true }
            loopSwipe()
            loopArrow()
        }
    }

    private func loopSwipe() {
        // Reset
        cardOffset = 0; cardRotation = 0; stampOpacity = 0; stampScale = 0.4; nextCardScale = 0.92
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Animate swipe right
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                cardOffset = 300; cardRotation = 18; stampOpacity = 1; stampScale = 1; nextCardScale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { loopSwipe() }
        }
    }
    private func loopArrow() {
        arrowPhase = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { arrowPhase = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { arrowPhase = 2 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { arrowPhase = 3 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { loopArrow() }
    }
}

// MARK: ─ Slide 2 · Swipe Left ───────────────────────────────────────────────

private struct Slide2View: View {
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var stampOpacity: Double = 0
    @State private var stampScale: CGFloat = 0.4
    @State private var nextCardScale: CGFloat = 0.92
    @State private var arrowPhase: Int = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.12))
                .frame(width: 220, height: 290)
                .scaleEffect(nextCardScale)
                .offset(y: 8)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    )

                VStack(spacing: 12) {
                    Text("🥦")
                        .font(.system(size: 64))
                    Text("Broccoli Soup")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Vegetarian · 20 min")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.65))
                }

                // NOPE stamp
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(red: 0.98, green: 0.30, blue: 0.30), lineWidth: 3)
                        .frame(width: 100, height: 38)
                    Text("NOPE ✗")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color(red: 0.98, green: 0.30, blue: 0.30))
                }
                .rotationEffect(.degrees(18))
                .offset(x: 44, y: -80)
                .opacity(stampOpacity)
                .scaleEffect(stampScale)
            }
            .frame(width: 220, height: 290)
            .rotationEffect(.degrees(cardRotation))
            .offset(x: cardOffset)
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 12)

            // Animated arrows — left side
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: -4) {
                        ForEach((0..<3).reversed(), id: \.self) { i in
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white.opacity(arrowPhase > i ? 0.9 : 0.2))
                                .animation(.easeInOut(duration: 0.25).delay(Double(i) * 0.08), value: arrowPhase)
                        }
                    }
                    Text("swipe")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 4)
                }
                .padding(.leading, 8)
                Spacer()
            }
            .frame(width: 300)
        }
        .frame(height: 340)
        .onAppear { loopSwipe(); loopArrow() }
    }

    private func loopSwipe() {
        cardOffset = 0; cardRotation = 0; stampOpacity = 0; stampScale = 0.4; nextCardScale = 0.92
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                cardOffset = -300; cardRotation = -18; stampOpacity = 1; stampScale = 1; nextCardScale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { loopSwipe() }
        }
    }
    private func loopArrow() {
        arrowPhase = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { arrowPhase = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { arrowPhase = 2 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { arrowPhase = 3 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { loopArrow() }
    }
}

// MARK: ─ Slide 3 · Meal Plan ────────────────────────────────────────────────

private struct Slide3View: View {
    @State private var appear = false
    @State private var visibleRows: Int = 0
    @State private var checkmarks: [Bool] = [false, false, false]
    @State private var bellBounce: CGFloat = 1
    @State private var floatY: CGFloat = 0

    private let days = [
        ("Mon", "🍝", "Pasta Carbonara"),
        ("Wed", "🍛", "Chicken Curry"),
        ("Fri", "🥩", "Beef Steak"),
    ]

    var body: some View {
        ZStack {
            // Calendar card
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("March 2026")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                        Text("My Meal Plan")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .scaleEffect(bellBounce)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 14)

                Divider().background(.white.opacity(0.2))

                // Rows
                VStack(spacing: 0) {
                    ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                        if visibleRows > i {
                            HStack(spacing: 12) {
                                Text(day.0)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(width: 30)
                                Text(day.1)
                                    .font(.system(size: 22))
                                Text(day.2)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: checkmarks[i] ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(checkmarks[i] ? Color(red: 0.32, green: 0.46, blue: 0.95) : .white.opacity(0.3))
                                    .scaleEffect(checkmarks[i] ? 1.15 : 1)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .transition(.move(edge: .trailing).combined(with: .opacity))

                            if i < days.count - 1 {
                                Divider().background(.white.opacity(0.12)).padding(.leading, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
            }
            .background(.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(.white.opacity(0.22), lineWidth: 1))
            .frame(width: 280)
            .offset(y: floatY)
            .shadow(color: .black.opacity(0.25), radius: 22, x: 0, y: 12)
        }
        .frame(height: 320)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: visibleRows)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: checkmarks)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) { floatY = -7 }
            loopRows()
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { bellBounce = 1.2 }
        }
    }

    private func loopRows() {
        visibleRows = 0; checkmarks = [false, false, false]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)  { withAnimation { visibleRows = 1 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { withAnimation { visibleRows = 2 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1)  { withAnimation { visibleRows = 3 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7)  { withAnimation { checkmarks[0] = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)  { withAnimation { checkmarks[1] = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3)  { withAnimation { checkmarks[2] = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2)  { loopRows() }
    }
}

// MARK: ─ Slide 4 · Translation ──────────────────────────────────────────────

private struct Slide4View: View {
    @State private var appear = false
    @State private var currentLang: Int = 0
    @State private var textOpacity: Double = 1
    @State private var textOffset: CGFloat = 0
    @State private var globe1Rotation: Double = 0
    @State private var globe2Rotation: Double = 0
    @State private var floatY: CGFloat = 0
    @State private var flagScale: CGFloat = 1

    private let langs: [(flag: String, code: String, text: String)] = [
        ("🇬🇧", "EN", "Chicken Tikka Masala"),
        ("🇹🇷", "TR", "Tavuk Tikka Masala"),
        ("🇫🇷", "FR", "Poulet Tikka Masala"),
        ("🇪🇸", "ES", "Pollo Tikka Masala"),
        ("🇮🇹", "IT", "Pollo Tikka Masala")
    ]

    var body: some View {
        ZStack {
            // Spinning orbit ring
            Circle()
                .strokeBorder(
                    AngularGradient(colors: [.white.opacity(0.4), .clear, .white.opacity(0.2), .clear],
                                   center: .center),
                    lineWidth: 2
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(globe1Rotation))
                .scaleEffect(appear ? 1 : 0.6)

            Circle()
                .strokeBorder(
                    AngularGradient(colors: [.clear, .white.opacity(0.25), .clear, .white.opacity(0.15)],
                                   center: .center),
                    lineWidth: 1
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(globe2Rotation))

            // Globe icon
            Image(systemName: "globe.europe.africa.fill")
                .font(.system(size: 72))
                .foregroundStyle(.white)
                .scaleEffect(appear ? 1 : 0.3)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)

            // Translation card
            VStack(spacing: 6) {
                Text(langs[currentLang].flag + " " + langs[currentLang].code)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                Text(langs[currentLang].text)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(.white.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.3), lineWidth: 1))
            .opacity(textOpacity)
            .offset(y: 105 + textOffset + floatY)
            .shadow(color: .black.opacity(0.2), radius: 10, y: 4)

            // Flag dots on orbit
            ForEach(Array(langs.enumerated()), id: \.offset) { i, lang in
                let angle = Double(i) * 72.0 - 90.0 + globe1Rotation
                Text(lang.flag)
                    .font(.system(size: 20))
                    .offset(
                        x: cos(angle * .pi / 180) * 118,
                        y: sin(angle * .pi / 180) * 118
                    )
                    .scaleEffect(currentLang == i ? flagScale : 0.85)
                    .opacity(appear ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.65).delay(Double(i) * 0.07), value: appear)
            }
        }
        .frame(height: 340)
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.68)) { appear = true }
            withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) { globe1Rotation = 360 }
            withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) { globe2Rotation = -360 }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { floatY = -6 }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { flagScale = 1.25 }
            loopLangs()
        }
    }

    private func loopLangs() {
        withAnimation(.easeIn(duration: 0.2)) { textOpacity = 0; textOffset = -8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            currentLang = (currentLang + 1) % langs.count
            textOffset = 8
            withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) { textOpacity = 1; textOffset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { loopLangs() }
        }
    }
}

#Preview {
    OnboardingView { }
}
