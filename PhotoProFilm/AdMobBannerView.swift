//
//  AdMobBannerView.swift
//  WallDota2
//
//  Created by QuangHo on 12/9/24.
//

import SwiftUI
import GoogleMobileAds
protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}


class BannerViewController: UIViewController {
    weak var delegate: BannerViewControllerWidthDelegate?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Tell the delegate the initial ad width.
        delegate?.bannerViewController(self, didUpdate: view.frame.inset(by: view.safeAreaInsets).size.width)
    }
}

struct AdMobBannerView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-7153595903380471/2911702088" // Replace with your actual Ad Unit ID
        
        // Use the correct way to find the root view controller in SwiftUI
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            bannerView.rootViewController = windowScene.windows.first?.rootViewController
        }
        
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // You may want to update the ad request or ad unit id if needed
    }

}


#Preview {
    AdMobBannerView()
}
