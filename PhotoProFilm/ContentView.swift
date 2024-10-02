import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Firebase
import NavigationTransitions
import FirebaseRemoteConfig

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isLogined: Bool = false
    @Published var isFirstInstall: Bool = false
    @Published var titleCategory: String = "Noise"
    @Published var currentStyle: ColorStyle = .cinematic
    @Published var forceUpdate: Bool = false
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

struct ContentView: View {
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var isShowPreviewImage = false
    @State var imageDetail: UIImage?
    @State var isFirstInstall = false
    
    @StateObject var appState = AppState()
    let context = CIContext()
    @State private var path = NavigationPath()
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack (path: $path) {
            VStack {
                if appState.isFirstInstall {
                    WrapperSplashScreen(path: $path, appState: appState)
                } else if appState.isLogined && Auth.auth().currentUser != nil {
                    CameraApplyView(path: $path)
                        .navigationBarBackButtonHidden()
//                    CategoryImageView(path: $path, actionSettingView: {
//                        path.append("Setting")
//                    })
                } else {
                    LoginView(path: $path, appState: appState)
                }
            }.navigationDestination(for: String.self) { value in
                switch Screen(rawValue: value) {
                case .setting:
                    SettingsView(path: $path)
                        .navigationBarBackButtonHidden()
                case .login:
                    LoginView(path: $path, appState: appState)
                        .navigationBarBackButtonHidden()
                case .category:
                    CategoryImageView(path: $path, actionSettingView: {
                        path.append("Setting")
                    })
                    .navigationBarBackButtonHidden()
                case .choosePicker:
                    ChooseImageView(path: $path)
                        .navigationBarBackButtonHidden()
                case .personalInfo:
                    PersonalInfoView(path: $path)
                        .navigationBarBackButtonHidden()
                case .aboutUs:
                    AboutUs()
                        .navigationBarBackButtonHidden()
                case .privacy:
                    Privacy()
                        .navigationBarBackButtonHidden()
                case .unknown:
                    Text("Unknown destination")
                case .instruction:
                    InstructionView(path: $path)
                        .navigationBarBackButtonHidden()
                case .photo:
                    CameraApplyView(path: $path)
                        .navigationBarBackButtonHidden()
                case .savePhoto:
                    SavePhotosView()
                        .navigationBarBackButtonHidden()
                }
            }
            .navigationTransition(.fade(.cross))
            .alert(isPresented: $appState.forceUpdate) {
                Alert(
                    title: Text("Update Required"),
                    message: Text("A newer version of the app is required. Please update to continue."),
                    primaryButton: .default(Text("Update"), action: {
                        // Redirect to the App Store or update page
                        if let url = URL(string: "itms-apps://apple.com/app/id6505014197") {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel(Text("Close App"), action: {
                        // Optionally close the app if an update is required
                        exit(0)
                    })
                )
            }
            .onAppear {
                appState.isLogined = AppSetting.checkLogined()
                appState.isFirstInstall = AppSetting.checkisFirstLogined()

            }
        }
    }
    
    
}
