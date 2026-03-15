import GoogleMobileAds
import Observation

private let kNativeAdUnitID = "ca-app-pub-3600325889588673/2640417531"

@MainActor
@Observable
final class NativeAdLoader: NSObject {

    var nativeAd: GADNativeAd?
    private(set) var isLoading = false

    private var adLoader: GADAdLoader?

    func load() {
        guard !isLoading else { return }
        isLoading = true
        nativeAd = nil

        let loader = GADAdLoader(
            adUnitID: kNativeAdUnitID,
            rootViewController: nil,
            adTypes: [.native],
            options: nil
        )
        loader.delegate = self
        adLoader = loader
        loader.load(GADRequest())
    }
}

extension NativeAdLoader: GADNativeAdLoaderDelegate {

    nonisolated func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        Task { @MainActor in
            self.nativeAd = nativeAd
            self.isLoading = false
        }
    }

    nonisolated func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        Task { @MainActor in
            self.isLoading = false
        }
    }
}
