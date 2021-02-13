import SwiftUI
import Combine
import WebKit

@dynamicMemberLookup
public class WebViewStore: ObservableObject {
  @Published public var webView: WKWebView {
    didSet {
      setupObservers()
    }
  }
  
  public init(webView: WKWebView = WKWebView()) {
    self.webView = webView
    setupObservers()
  }
  
  private func setupObservers() {
    func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
      return webView.observe(keyPath, options: [.prior]) { _, change in
        if change.isPrior {
          self.objectWillChange.send()
        }
      }
    }
    // Setup observers for all KVO compliant properties
    observers = [
      subscriber(for: \.title),
      subscriber(for: \.url),
      subscriber(for: \.isLoading),
      subscriber(for: \.estimatedProgress),
      subscriber(for: \.hasOnlySecureContent),
      subscriber(for: \.serverTrust),
      subscriber(for: \.canGoBack),
      subscriber(for: \.canGoForward)
    ]
  }
  
  private var observers: [NSKeyValueObservation] = []
  
  public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
    webView[keyPath: keyPath]
  }
}

#if os(iOS)
/// A container for using a WKWebView in SwiftUI
public struct WebView: View, UIViewRepresentable {
  /// The WKWebView to display
  public let webView: WKWebView
  
  public init(webView: WKWebView) {
    self.webView = webView
  }
  
  public  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WKWebView

    init(_ parent: WKWebView) {
        self.parent = parent
    }

    public func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        print("code here")
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("code here")
    }

    // Delegate methods go here
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("authenticationMethod \(challenge.protectionSpace.authenticationMethod)")
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM {
            let user = "username"
            let password = "password"
            let credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
            challenge.sender?.use(credential, for: challenge)
            completionHandler(.useCredential, credential)
        }else{
            completionHandler(.performDefaultHandling, nil);
        }
    }
  }

  public func makeCoordinator() -> Coordinator {
      Coordinator(self.webView)
  }
  
  public func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
    webView
  }
  
  public func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
    uiView.navigationDelegate = context.coordinator
  }
}
#endif

#if os(macOS)
/// A container for using a WKWebView in SwiftUI
public struct WebView: View, NSViewRepresentable {
  /// The WKWebView to display
  public let webView: WKWebView
  
  public init(webView: WKWebView) {
    self.webView = webView
  }
  
  public func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
    webView
  }
  
  public func updateNSView(_ uiView: WKWebView, context: NSViewRepresentableContext<WebView>) {
  }
}
#endif
