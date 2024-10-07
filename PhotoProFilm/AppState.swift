//
//  AppState.swift
//  PhotoProFilm
//
//  Created by QuangHo on 4/10/24.
//
import SwiftUI
import CoreImage
import PixelEnginePackage
import FirebaseRemoteConfig

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isLogined: Bool = false
    @Published var isFirstInstall: Bool = false
    @Published var titleCategory: String = "Noise"
    @Published var currentStyle: ColorStyle = .cinematic
    @Published var forceUpdate: Bool = false
    @Published var cubeSelected: FilterColorCube?
    var photoEdit: UIImage?
    let remoteConfig = RemoteConfig.remoteConfig()
        
    init() {
        self.isLogined = AppSetting.checkLogined()
        self.isFirstInstall = AppSetting.checkisFirstLogined()
        setupRemoteConfig()
        fetchRemoteConfig()
        
    }
    
    private func setupRemoteConfig() {
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 3600 // Fetch every hour
            remoteConfig.configSettings = settings
            remoteConfig.setDefaults(["min_required_version": "1.4" as NSObject])
        }
        
        func fetchRemoteConfig() {
            remoteConfig.fetch { [weak self] status, error in
                if status == .success {
                    self?.remoteConfig.activate { _, _ in
                        self?.checkAppVersion()
                    }
                } else if let error = error {
                    print("Error fetching remote config: \(error.localizedDescription)")
                }
            }
        }
        
        func checkAppVersion() {
            let minRequiredVersion = remoteConfig["min_required_version"].stringValue ?? "1.4"
            if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                if currentVersion.compare(minRequiredVersion, options: .numeric) == .orderedAscending {
                    // Trigger the force update process
                    forceUpdateApp()
                }
            }
        }
        
        private func forceUpdateApp() {
            // Implement the logic to show an alert or modal that forces the user to update the app
            print("App requires an update to version \(remoteConfig["min_required_version"].stringValue ?? "1.0.0")")
            DispatchQueue.main.async {
                self.forceUpdate = true
            }
            
        }
    
}
