import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Firebase
import NavigationTransitions
class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isLogined: Bool = false
    @Published var isFirstInstall: Bool = false
    @Published var titleCategory: String = "Noise"
    @Published var currentStyle: ColorStyle = .cinematic
    
    init() {
        self.isLogined = AppSetting.checkLogined()
        self.isFirstInstall = AppSetting.checkisFirstLogined()
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
    
    var body: some View {
        NavigationStack (path: $path) {
            VStack {
                if appState.isFirstInstall {
                    WrapperSplashScreen(path: $path, appState: appState)
                } else if appState.isLogined && Auth.auth().currentUser != nil {
                    CategoryImageView(path: $path, actionSettingView: {
                        path.append("Setting")
                    })
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
                }
            }
            .navigationTransition(.fade(.cross))
            .onAppear {
                appState.isLogined = AppSetting.checkLogined()
                appState.isFirstInstall = AppSetting.checkisFirstLogined()
            }
        }
    }
    
    
}
