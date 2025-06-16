import SwiftUI
import WebKit

struct ESPNGifLoadingIcon: UIViewRepresentable {
    let size: CGFloat
    
    init(size: CGFloat = 30) {
        self.size = size
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
        
        if let gifPath = Bundle.main.path(forResource: "ESPN_Loading_Icon", ofType: "gif"),
           let gifData = NSData(contentsOfFile: gifPath) {
            webView.load(gifData as Data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: gifPath))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed
    }
}

// SwiftUI wrapper to make it easier to use
struct ESPNGifLoader: View {
    let size: CGFloat
    
    init(size: CGFloat = 30) {
        self.size = size
    }
    
    var body: some View {
        ESPNGifLoadingIcon(size: size)
            .frame(width: size, height: size)
            .cornerRadius(size / 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        ESPNGifLoader(size: 60)
        ESPNGifLoader(size: 30)
    }
    .padding()
    .background(Color.black)
}