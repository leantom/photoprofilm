//
//  PhotoProFilmApp.swift
//  PhotoProFilm
//
//  Created by QuangHo on 13/5/24.
//

import SwiftUI
import FirebaseCore
import Firebase
import GoogleMobileAds
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      GADMobileAds.sharedInstance().start(completionHandler: nil)

      Task {
          LoginViewModel.shared.user = Auth.auth().currentUser
          let _ = await LoginViewModel.shared.getUserDetail()
      }
    return true
  }
}

@main
struct PhotoProFilmApp: App {
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PECtl.shared)
                .environmentObject(DataColor.shared)
        }
    }
}
