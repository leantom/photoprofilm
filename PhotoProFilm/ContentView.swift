import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Firebase
import NavigationTransitions
import FirebaseRemoteConfig

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
    @State var showingEdittor = false
    
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
                case .editPhoto:
                    EditPhotoCameraView(path: $path)
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
