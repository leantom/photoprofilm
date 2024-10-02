import SwiftUI
import NavigationTransitions

struct PagerView<Content: View>: View {
    @Binding var currentPage: Int
    let pageCount: Int
    let content: Content

    init(currentPage: Binding<Int>, pageCount: Int, @ViewBuilder content: () -> Content) {
        self._currentPage = currentPage
        self.pageCount = pageCount
        self.content = content()
    }

    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            HStack(spacing: 0) {
                content
                    .frame(width: width)
                    .offset(x: -CGFloat(currentPage) * width + dragOffset)
                    .animation(.easeInOut, value: currentPage)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width < -threshold && currentPage < pageCount - 1 {
                                    currentPage += 1
                                }
                                if value.translation.width > threshold && currentPage > 0 {
                                    currentPage -= 1
                                }
                            }
                    )
            }
        }
        .clipped()
    }
}

struct SplashScreenView: View {
    var screen: SplashScreen
    var actionStart: (() -> Void)
    var actionNext: (() -> Void)
    
    var body: some View {
        ZStack {
            // Background Image
            GeometryReader { geometry in
                Image(screen.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .edgesIgnoringSafeArea(.all)
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.3), Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            // Content
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Text(screen.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fontWidth(.condensed)
                    
                    Text(screen.description)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fontWidth(.condensed)
                    // Buttons
                    HStack(spacing: 20) {
//                        Button(action: {
//                            //MARK: -- Skip action
//                            actionStart()
//                        }) {
//                            Text("Skip")
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.purple.opacity(0.3))
//                                .foregroundColor(.white)
//                                .fontWidth(.condensed)
//                                .cornerRadius(10)
//                        }
                        
                        Button(action: {
                            // Next action
                            if screen.typeSplash == .start {
                                actionStart()
                            } else {
                                actionNext()
                            }
                        }) {
                            Text(screen.buttonText)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .fontWidth(.condensed)
                                .cornerRadius(10)
                        }
                        
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
                .padding()
                
                Spacer()
            }
        }
        .background(.red)
    }
}

struct WrapperSplashScreen: View {
    let splashScreens = [
        SplashScreen(imageName: "film", title: "Relive the Classics", description: "Transform your photos with timeless elegance. Embrace the charm of classic film aesthetics and create lasting memories.", buttonText: "Next", typeSplash: .skip),
        SplashScreen(imageName: "cinematic", title: "Retro Creativity Unleashed", description: "Dive into a world of retro-inspired tools. Use our AI toolbox to give your photos a vintage touch and showcase your artistic flair.", buttonText: "Next", typeSplash: .skip),
        SplashScreen(imageName: "avatar", title: "Renaissance of Photography", description: "Explore the Renaissance style for your photography. Use advanced features to create inspiring works of art.", buttonText: "Get Started", typeSplash: .start)
    ]

    @State private var currentPage = 0
    @Binding var path: NavigationPath
    @ObservedObject var appState: AppState

    var body: some View {
        PagerView(currentPage: $currentPage, pageCount: splashScreens.count) {
            ForEach(0..<splashScreens.count, id: \.self) { index in
                SplashScreenView(
                    screen: splashScreens[index],
                    actionStart: {
                        appState.isLogined = AppSetting.checkLogined()
                        AppSetting.setFirstLogined(value: false)
                        path.append("Login")
                    },
                    actionNext: {
                        withAnimation {
                            if currentPage < splashScreens.count - 1 {
                                currentPage += 1
                            } else {
                                appState.isLogined = AppSetting.checkLogined()
                                AppSetting.setFirstLogined(value: false)
                                path.append("Login")
                            }
                        }
                    }
                )
                .frame(width: UIScreen.main.bounds.width)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct WrapperSplash: View {
    @State var path = NavigationPath()
    @State var appState = AppState()
    var body: some View {
        WrapperSplashScreen(path: $path, appState: appState)
    }
}

#Preview {
    WrapperSplash()
}
