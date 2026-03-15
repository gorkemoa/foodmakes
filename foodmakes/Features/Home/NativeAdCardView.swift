import SwiftUI
import GoogleMobileAds

// MARK: - Swipeable Native Ad Card
struct NativeAdCardView: View {

    let loader: NativeAdLoader
    let onDismiss: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var cardAppeared = false

    private let swipeThreshold: CGFloat = 110

    private var skipOpacity: Double  { max(0, Double(-dragOffset.width / swipeThreshold) - 0.05) }
    private var okOpacity: Double    { max(0, Double( dragOffset.width / swipeThreshold) - 0.05) }
    private var rotation: Double     { Double(dragOffset.width / 20) }
    private var liftY: CGFloat       { -abs(dragOffset.width) * 0.03 }

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Ad content / placeholder ───────────────────────────────────
            // NOTE: No clipShape on NativeAdUIViewRepresentable — SwiftUI's
            // clipping wrapper inserts an extra UIView layer that breaks
            // AdMob's asset-containment check. Corner clipping is handled
            // inside UIKit via layer.cornerRadius + clipsToBounds.
            if let ad = loader.nativeAd {
                NativeAdUIViewRepresentable(ad: ad)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(.systemGray5), Color(.systemGray4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    VStack(spacing: 14) {
                        ProgressView()
                            .tint(.orange)
                            .scaleEffect(1.4)
                        Text("Ad Loading...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }

            // ── Swipe direction stamps ─────────────────────────────────────
            VStack {
                HStack {
                    AdStampLabel(text: "SKIP", color: .dislikeRed, angle: -13)
                        .opacity(skipOpacity)
                        .scaleEffect(0.85 + skipOpacity * 0.15)
                        .padding(.leading, 24)
                    Spacer()
                    AdStampLabel(text: "OK", color: .tryGreen, angle: 13)
                        .opacity(okOpacity)
                        .scaleEffect(0.85 + okOpacity * 0.15)
                        .padding(.trailing, 24)
                }
                .padding(.top, 60)
                Spacer()
            }

            // ── "Ad" badge ─────────────────────────────────────────────────
            VStack {
                HStack {
                    Spacer()
                    Text("Ad")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.50), in: Capsule())
                        .padding(.top, 14)
                        .padding(.trailing, 14)
                }
                Spacer()
            }
        }
        .shadow(color: .black.opacity(0.13), radius: 20, x: 0, y: 8)
        .rotationEffect(.degrees(rotation))
        .offset(y: liftY)
        .offset(dragOffset)
        .scaleEffect(cardAppeared ? 1 : 0.92)
        .opacity(cardAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.50, dampingFraction: 0.75)) {
                cardAppeared = true
            }
            loader.load()
        }
        .gesture(
            DragGesture(minimumDistance: 6)
                .onChanged { value in
                    withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.86)) {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    let vx = value.predictedEndTranslation.width
                    if vx < -swipeThreshold || vx > swipeThreshold {
                        let dir: CGFloat = vx > 0 ? 1 : -1
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                            dragOffset = CGSize(width: dir * 700, height: dragOffset.height * 0.4 - 20)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                            onDismiss()
                        }
                    } else {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.68)) {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }
}

// MARK: - Stamp Label (local copy for this card)
private struct AdStampLabel: View {
    let text: String; let color: Color; let angle: Double
    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .rotationEffect(.degrees(angle))
    }
}

// MARK: - UIKit GADNativeAdView wrapper

// NativeAdContainerView owns GADNativeAdView as a plain subview so SwiftUI
// never wraps it with clipping or transform layers. The nativeAd assignment
// happens inside layoutSubviews() after calling adView.layoutIfNeeded(),
// guaranteeing that every registered asset-view frame is non-zero before
// AdMob's containment validator runs.
private struct NativeAdUIViewRepresentable: UIViewRepresentable {

    let ad: GADNativeAd

    func makeUIView(context: Context) -> NativeAdContainerView {
        NativeAdContainerView()
    }

    func updateUIView(_ uiView: NativeAdContainerView, context: Context) {
        uiView.update(ad: ad)
    }
}

// MARK: -

private final class NativeAdContainerView: UIView {

    private let adView = GADNativeAdView()
    private var pendingAd: GADNativeAd?
    private var populatedAdID: ObjectIdentifier?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        buildAdView()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(ad: GADNativeAd) {
        let id = ObjectIdentifier(ad)
        guard id != populatedAdID else { return }
        pendingAd = ad
        setNeedsLayout()
    }

    // layoutSubviews is the earliest point at which the adView and all its
    // subviews have resolved frames. Calling adView.layoutIfNeeded() first
    // forces adView's own layout pass synchronously, making every asset frame
    // non-zero before nativeAd is assigned.
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let ad = pendingAd, bounds.width > 0 else { return }
        pendingAd = nil
        populatedAdID = ObjectIdentifier(ad)
        adView.layoutIfNeeded()
        populateAdView(with: ad)
    }

    // MARK: - Construction

    private func buildAdView() {
        adView.clipsToBounds = true
        adView.backgroundColor = .black
        adView.layer.cornerRadius = 22
        adView.layer.cornerCurve = .continuous

        // ── Media ─────────────────────────────────────────────────────────
        let mediaView = GADMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        adView.mediaView = mediaView
        adView.addSubview(mediaView)

        // ── Gradient overlay ──────────────────────────────────────────────
        let gradient = AdGradientView()
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.isUserInteractionEnabled = false
        adView.addSubview(gradient)

        // ── Advertiser label ──────────────────────────────────────────────
        let advertiserLabel = UILabel()
        advertiserLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        advertiserLabel.textColor = UIColor.white.withAlphaComponent(0.70)
        advertiserLabel.numberOfLines = 1
        advertiserLabel.translatesAutoresizingMaskIntoConstraints = false
        adView.advertiserView = advertiserLabel
        adView.addSubview(advertiserLabel)

        // ── Headline label ────────────────────────────────────────────────
        let headlineLabel = UILabel()
        headlineLabel.font = .systemFont(ofSize: 26, weight: .bold)
        headlineLabel.textColor = .white
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        adView.headlineView = headlineLabel
        adView.addSubview(headlineLabel)

        // ── Body label ────────────────────────────────────────────────────
        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 12, weight: .regular)
        bodyLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        bodyLabel.numberOfLines = 2
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        adView.bodyView = bodyLabel
        adView.addSubview(bodyLabel)

        // ── CTA button ────────────────────────────────────────────────────
        var cfg = UIButton.Configuration.filled()
        cfg.baseBackgroundColor = .systemOrange
        cfg.baseForegroundColor = .white
        cfg.cornerStyle = .medium
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = .systemFont(ofSize: 14, weight: .semibold); return a
        }
        let ctaButton = UIButton(configuration: cfg)
        ctaButton.isUserInteractionEnabled = false   // GADNativeAdView handles taps
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        adView.callToActionView = ctaButton
        adView.addSubview(ctaButton)

        // ── Constraints: adView fills container ───────────────────────────
        adView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(adView)
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: topAnchor),
            adView.leadingAnchor.constraint(equalTo: leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: trailingAnchor),
            adView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // ── Constraints: NON-OVERLAPPING asset layout ─────────────────────
        // AdMob rule: no registered asset view (mediaView, advertiserView,
        // headlineView, bodyView, callToActionView) may overlap another
        // registered asset. mediaView occupies the top 58%; all text assets
        // are stacked below it in the remaining 42% — zero frame overlap.
        NSLayoutConstraint.activate([
            // Media: top 58% of card
            mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaView.heightAnchor.constraint(equalTo: adView.heightAnchor, multiplier: 0.58),

            // Gradient: decoration over bottom edge of media only (not an asset)
            gradient.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: mediaView.bottomAnchor),
            gradient.heightAnchor.constraint(equalTo: mediaView.heightAnchor, multiplier: 0.35),

            // Advertiser: first row below media
            advertiserLabel.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 14),
            advertiserLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 20),
            advertiserLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20),

            // Headline: below advertiser
            headlineLabel.topAnchor.constraint(equalTo: advertiserLabel.bottomAnchor, constant: 4),
            headlineLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 20),
            headlineLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20),

            // Body: below headline
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 6),
            bodyLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -20),

            // CTA: below body, must not exceed card bottom
            ctaButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 14),
            ctaButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 20),
            ctaButton.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: - Population

    private func populateAdView(with ad: GADNativeAd) {
        if let label = adView.advertiserView as? UILabel {
            let kern: [NSAttributedString.Key: Any] = [
                .kern: CGFloat(1.8),
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.70)
            ]
            label.attributedText = NSAttributedString(
                string: (ad.advertiser ?? "SPONSORED").uppercased(),
                attributes: kern
            )
        }
        (adView.headlineView as? UILabel)?.text = ad.headline
        if let bodyLabel = adView.bodyView as? UILabel {
            bodyLabel.text = ad.body
            bodyLabel.isHidden = (ad.body == nil || ad.body?.isEmpty == true)
        }
        if let btn = adView.callToActionView as? UIButton {
            btn.setTitle(ad.callToAction, for: .normal)
        }
        adView.mediaView?.mediaContent = ad.mediaContent
        // nativeAd MUST be last — triggers AdMob's asset-containment validation
        adView.nativeAd = ad
    }
}

// MARK: - Gradient helper UIView
private final class AdGradientView: UIView {
    private let grad = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        grad.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.62).cgColor]
        grad.locations = [0.30, 1.0]
        grad.startPoint = CGPoint(x: 0.5, y: 0)
        grad.endPoint   = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(grad)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        grad.frame = bounds
    }
}
