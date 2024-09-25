//
//  LoginViewModel.swift
//  WallDota2
//
//  Created by QuangHo on 19/12/2023.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignInSwift
import GoogleSignIn
import Firebase
import AuthenticationServices
import CryptoKit

class AppleSignInHandler: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var currentNonce: String = ""
    var actionLoginSuccessfully:(()->Void)?
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the first window in the current window scene as the presentation anchor for the ASAuthorizationController
        return UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .flatMap { $0?.windows.first } ?? UIApplication.shared.windows.first!
    }
    
    
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Apple Sign In was successful.
            // You can now use the `appleIDCredential` to authenticate the user in your app.
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: self.currentNonce,
                                                           fullName: appleIDCredential.fullName)
            // Exchange Apple ID token for Firebase credential
            Auth.auth().signIn(with: credential) { [self] (authResult, error) in
                if let err = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(err.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                
                if let result = authResult {
                    Task {
                        await LoginViewModel.shared.createUser(user: result.user, provider: "apple")
                        LoginViewModel.shared.user = result.user
                        AppSetting.setLogined(value: true)
                        actionLoginSuccessfully?()
                    }
                    
                } else {
                    Task {
                        await LoginViewModel.shared.signinWithAnynomous()
                        actionLoginSuccessfully?()
                    }
                }
                
            }
            
            //             print("Apple Sign In was successful. User's full name is: \(userFullName)")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Apple Sign In failed.
        // You can handle the error here.
        print("Apple Sign In failed with error: \(error.localizedDescription)")
    }
}

enum SignInMethod {
    case Apple
    case Google
    case Anonymous
    case Twitter
}

class LoginViewModel: NSObject, ObservableObject {
    static let shared = LoginViewModel()
    
    var isLoggedIn: Bool = false
    var user:User? // user from authenticantion
    var userLogin:NewUser? // user from firestore
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false)
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        DispatchQueue.main.async {
            // Access UI-related elements on the main thread
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let presentingVC = windowScene.keyWindow?.rootViewController else {
                completion(false)
                return
            }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { user, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }
                
                guard let user = user else {
                    completion(false)
                    return
                }
                
                let credential = GoogleAuthProvider.credential(
                    withIDToken: user.user.idToken?.tokenString ?? "",
                    accessToken: user.user.accessToken.tokenString
                )
                
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                        return
                    }
                    
                    guard let result = result else {
                        completion(false)
                        return
                    }
                    
                    LoginViewModel.shared.user = result.user
                    AppSetting.setLogined(value: true)
                    
                    Task {
                        await self.createUser(user: result.user, provider: "google")
                        completion(result.credential != nil)
                    }
                }
            }
        }
    }

    
    func createUser(user: User, provider: String) async {
        let now = Date().timeIntervalSince1970
        let suffix = "\(now)".suffix(6)
        var username = "anonymous\(suffix)"
        if let email = user.email {
            let components = email.components(separatedBy: "@")
            if let first = components.first {
                username = first
            }
        }
        
        let newUser = NewUser(username: username, email: user.email ?? "\(username)@profilm.com", providers: provider, created_at: now, last_login_at: now, userid: user.uid, avatar: randomAvatar())
        
        LoginViewModel.shared.userLogin = newUser
        await UserViewModel.shared.createUser(user: newUser)
    }
    
    func randomAvatar() -> String {
        var listImage = ["avatar", "BW", "cinematic", "contrast_1", "film", "noise", "selfie", "vivid"]
        var images: [UIImage] = []
        for image_name in listImage {
            if let img = UIImage(named: image_name) {
                images.append(img)
            }
            
        }
        if let randomImageName = images.randomElement(),
           let downsizedImage = randomImageName.resizeImage(targetSize: CGSize(width: 100, height: 100)),
           let base64String = downsizedImage.convertToBase64String() {
           return base64String
        }
        return ""
    }
    
    func addDevice() async {
        let db = Firestore.firestore()
        // Get the device token from Firebase Authentication or other methods
        let deviceToken = AppSetting.shared.fcmToken
        
        // Get the current user's UID
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Save the device token under the user's UID
        do {
            try await db.collection("devices").document(userID).setData(["token": deviceToken])
        } catch let err{
            print(err.localizedDescription)
        }
        
    }
    // MARK: -- checkExistUser
    func checkExistUser(userName: String) async -> Bool{
        let db = Firestore.firestore()
        let documentRef = db.collection("users").whereField("username", isEqualTo: userName)
        do {
            let snapshot = try await documentRef.getDocuments()
            if snapshot.documents.count > 0 {
                return false
            }
            return true
        } catch let err{
            print(err.localizedDescription)
            return false
        }
    }
    
    //MARK: -- Update username
    func updateUserName(userName: String) async -> Bool {
        let db = Firestore.firestore()
        
        // check username exist yet
        let isValid = await checkExistUser(userName: userName)
        
        if isValid {
            let collectionRef = db.collection("users").whereField("userid", isEqualTo: user?.uid ?? "")
            
            do {
                let snapshot = try await collectionRef.getDocuments()
                let query = snapshot.documents.first
                
                try await query?.reference.updateData(["username": userName])
                LoginViewModel.shared.userLogin =  await getUserDetail()
                return true
            } catch let err{
                print(err.localizedDescription)
                return false
            }
            
        }
        
        
        
        return isValid
        
    }
    
    func updateAvatar(avatar: String) async  {
        let db = Firestore.firestore()
        
        // check username exist yet
        guard let user = LoginViewModel.shared.userLogin else {return }
        
        let collectionRef = db.collection("users").whereField("userid", isEqualTo: user.userid)
        
        do {
            let snapshot = try await collectionRef.getDocuments()
            let query = snapshot.documents.first
            
            try await query?.reference.updateData(["avatar": avatar])
            LoginViewModel.shared.userLogin =  await getUserDetail()
            return
        } catch let err{
            print(err.localizedDescription)
            return 
        }
        
        
    }
    
    
    
    //MARK: -- getUserDetail
    
    func getUserDetail() async -> NewUser? {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").whereField("userid", isEqualTo: user?.uid ?? "")
        do {
            
            let results = try await collectionRef.getDocuments()
            if let result = results.documents.first {
                let user = try result.data(as: NewUser.self)
                //MARK: update last login time
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    LoginViewModel .shared.userLogin = user
                }
                
                return user
                
            }
        } catch let err{
            print(err.localizedDescription)
            return nil
        }
        
        return nil
    }
    
    
    func signinWithAnynomous() async {
        do {
            
            if let user = Auth.auth().currentUser {
                AppSetting.setLogined(value: true)
                return
            }
            let result = try await Auth.auth().signInAnonymously()
            self.user = result.user
            print(user?.uid ?? "")
            AppSetting.setLogined(value: true)
            
            let now = Date().timeIntervalSince1970
            let suffix = "\(now)".suffix(6)
            let username = "anonymous\(suffix)"
            
            let newUser = NewUser(username: username, email: "\(username)@profilm.com", providers: "anonymous", created_at: now, last_login_at: now, userid: result.user.uid, avatar: randomAvatar())
            LoginViewModel.shared.userLogin = newUser
            await UserViewModel.shared.createUser(user: newUser)
        } catch let err{
            print(err.localizedDescription)
        }
        
    }
    
    func deleteUser() async {
        do {
            AppSetting.setLogined(value: false)
            guard let currentUser = user else { return  }
            
            let db = Firestore.firestore()
            let collectionRef = db.collection("users").whereField("userid", isEqualTo: user?.uid ?? "")
            let results = try await collectionRef.getDocuments()
            
            for item in results.documents {
                try await item.reference.delete()
            }
            
            try await currentUser.delete()
        } catch let err{
            print(err.localizedDescription)
        }
    }
    
    func logOut() {
        AppSetting.setLogined(value: false)
        AppSetting.setFirstLogined(value: true)
    }
    
    
}
