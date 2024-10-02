import SwiftUI

struct ExportChooseSizeView: View {
    let resolutions = [
        ("360 x 640", CGSize(width: 360, height: 640), false),
        ("480 x 854", CGSize(width: 480, height: 854), false),
        ("720 x 1280", CGSize(width: 720, height: 1280), true),
        ("1080 x 1920", CGSize(width: 1080, height: 1920), true),
        ("1440 x 2560", CGSize(width: 1440, height: 2560), true),
        ("2160 x 3840", CGSize(width: 2160, height: 3840), true),
        ("4320 x 7680", CGSize(width: 4320, height: 7680), true)
    ]
    var onSizeChosen: (CGSize) -> Void
    @State private var selectedSize: CGSize?
    @Environment(\.dismiss) var dismiss
    @State private var adsShownToday: Int = 0
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("Save Results")
                .font(.headline)
                .padding()
            
            List(resolutions, id: \.0) { resolution, size, isPro in
                Button(action: {
                    selectedSize = size
                    if isPro {
                        if adsShownToday < 5 {
                            showAlert = true
                        } else {
                            onSizeChosen(size)
                            dismiss()
                        }
                    } else {
                        onSizeChosen(size)
                        dismiss()
                    }
                }) {
                    HStack (spacing: 20){
                        Text(resolution)
                        if isPro {
                            Text("Recommended")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.purple)
                                .cornerRadius(10)
                            
                            Text("Ads")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.4))
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 45)
                    .padding(.vertical, 5)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        .onAppear {
            resetAdCounterIfNeeded()
            // Set up the ad dismissed handler
            InterstitialViewModel.shared.adDismissedHandler = {
                if let size = selectedSize {
                    onSizeChosen(size)
                    dismiss()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text("Sorry for showing ads, but we need revenue to maintain the server. We only show ads 5 times per day. Thank you for understanding."),
                dismissButton: .default(Text("OK"), action: {
                    showAd()
                })
            )
        }
    }
    
    func resetAdCounterIfNeeded() {
        let today = Date()
        let calendar = Calendar.current
        let lastResetDate = UserDefaults.standard.object(forKey: "adLastResetDate") as? Date ?? Date.distantPast
        if !calendar.isDate(today, inSameDayAs: lastResetDate) {
            // It's a new day, reset the counter
            UserDefaults.standard.set(0, forKey: "adsShownToday")
            UserDefaults.standard.set(today, forKey: "adLastResetDate")
        }
        adsShownToday = UserDefaults.standard.integer(forKey: "adsShownToday")
    }
    
    func showAd() {
        // Increment the counter
        adsShownToday += 1
        UserDefaults.standard.set(adsShownToday, forKey: "adsShownToday")
#if RELEASE
        // Show the ad
        DispatchQueue.main.async {
            InterstitialViewModel.shared.showAd()
        }
#endif
    }
}

struct WrapperExportView: View {
    var body: some View {
        ExportChooseSizeView { size in
            print(size)
        }
    }
}

#Preview {
    WrapperExportView()
}
