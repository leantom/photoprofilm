import SwiftUI
import SDWebImageSwiftUI
import NavigationTransitions

struct PersonalInfoView: View {
    @State private var username = "Andrew Ainsley"
    @State private var email = "andrew.ainsley@yourdomain.com"
    @State private var dateOfBirth = Date()
    @State private var gender = "Male"
    @State private var address = ""
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @Environment(\.dismiss) var dismiss
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var showingImagePicker = false
    @State private var showActionSheet = false
    @Binding var path: NavigationPath
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            VStack {
                ProfilePictureView(actionBack:  {
                    dismiss()
                }, actionChoosePicker: {
                    showActionSheet.toggle()
                }, image: self.image)

                Form {
                    Section(header: Text("Username")) {
                        TextField("Username", text: $username)
                    }
                    
                    Section(header: Text("Email")) {
                        HStack {
                            TextField("Email", text: $email)
                            Spacer()
                            Image(systemName: "envelope")
                        }
                    }
                   
                    
                    Section(header: Text("Date of Birth")) {
                        DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden() // Hide the default label
                    }
                    
                }
                .scrollDismissesKeyboard(.immediately)
                .onAppear {
                    guard let user = LoginViewModel.shared.userLogin else {return}
                    self.username = user.username
                    self.email = user.email
                    
                }
                Spacer()
                
                Button(action: {
                    guard let user = LoginViewModel.shared.userLogin else {return}
                    self.isLoading.toggle()
                    Task {
                        if self.username == user.username {
                            let isValid =  await LoginViewModel.shared.updateUserName(userName:username)
                        }
                        self.isLoading.toggle()
                    }
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding()
            }
            if isLoading {
                if let path = Bundle.main.path(forResource: "loading", ofType: "gif") {
                    let url = URL(fileURLWithPath: path)
                    VStack {
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                        
                        Text("Loging...")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fontWidth(.condensed)
                    }
                    .frame(height: 500)
                    
                }
            }
        }
        
        .onAppear(perform: {
            guard let user = LoginViewModel.shared.userLogin else {return}
            if let uiImage = decodeBase64StringToUIImage(base64String: user.avatar) {
                image = Image(uiImage: uiImage)
            }
        })
        .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(title: Text("Select Image"), message: Text("Choose a source"), buttons: [
                            .default(Text("Photo Library")) {
                                sourceType = .photoLibrary
                                showingImagePicker = true
                            },
                            .default(Text("Camera")) {
                                sourceType = .camera
                                showingImagePicker = true
                            },
                            .cancel()
                        ])
                    }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            CymeImagePicker(image: $inputImage, sourceType: sourceType)
        }
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        Task {
            if let downsizedImage = inputImage.resizeImage(targetSize: CGSize(width: 100, height: 100)),
                let base64String = downsizedImage.convertToBase64String() {
                
                await LoginViewModel.shared.updateAvatar(avatar: base64String)
            }
        }
    }
    
    func decodeBase64StringToUIImage(base64String: String) -> UIImage? {
            guard let imageData = Data(base64Encoded: base64String) else { return nil }
            return UIImage(data: imageData)
        }
}

struct ProfilePictureView: View {
    var actionBack: (() -> Void)
    var actionChoosePicker: (() -> Void)
    var image: Image?
    
    var body: some View {
        ZStack {
            VStack {
                if let img = self.image {
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .cornerRadius(100)
                        .padding()
                } else {
                    Image("avatar")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(100)
                        .padding()
                }
                
                    
                Button(action: {
                    // Edit profile picture action
                    actionChoosePicker()
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .resizable() // Make the image resizable
                                        .aspectRatio(contentMode: .fit) // Maintain the aspect ratio
                        .foregroundColor(.purple)
                        .frame(height:35)
                        .background(Circle().fill(Color.white))
                        
                }
                .offset(x: 35, y: -45)
            }
            VStack {
                HStack() {
                    Button(action: {
                        // Edit profile picture action
                        actionBack()
                    }) {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.black)
                            .padding()
                    }
                    .padding()
                    Spacer()
                }
                .frame(height: 55)
                Spacer()
            }
            
        }
        .onAppear {
            
        }
        
    }
    
    
    
}

struct WrappedPersonalInfo: View {
    @State var path =  NavigationPath()
    var body: some View {
        PersonalInfoView(path:$path)
    }
}

#Preview {
    WrappedPersonalInfo()
}
