//
//  WebView.swift
//  webview-test
//
//  Created by Jaesik Kim on 2022/03/04.
//

import SwiftUI
import WebKit
import Combine

protocol WebViewHandlerDelegate {
    func receivedJsonValueFromWebView(value: [String: Any?])
}

struct SwiftUIWebView: UIViewRepresentable, WebViewHandlerDelegate {
    
    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON from React app")
        print(value)
        viewModel.showAlert.send(true)
    }
    
    let url: URL?
    @ObservedObject var viewModel: WebViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        config.userContentController.add(self.makeCoordinator(), name: "SOME_BRIDGE")
        
        let webview = WKWebView(frame: .zero, configuration: config)
        
        webview.navigationDelegate = context.coordinator
        webview.allowsBackForwardNavigationGestures = false
        webview.scrollView.isScrollEnabled = true
        
        return webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let myUrl = url else {
            return
        }
        let request = URLRequest(url: myUrl)
        uiView.load(request)
    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        var parent: SwiftUIWebView
        var callbackValueFromNative: AnyCancellable? = nil
        
        var delegate: WebViewHandlerDelegate?
        
        init(_ uiWebView: SwiftUIWebView) {
            self.parent = uiWebView
            self.delegate = parent
        }
        
        deinit {
            callbackValueFromNative?.cancel()
        }
        
        func webView(_ webview: WKWebView, didFinish: WKNavigation!) {
            webview.evaluateJavaScript("document.title") { (response, error) in
                if let error = error {
                    print("title error")
                    print(error)
                }
                if let title = response as? String {
                    self.parent.viewModel.webTitle.send(title)
                }
            }
            
            self.callbackValueFromNative = self.parent.viewModel.callbackValueFromNative
                .receive(on: RunLoop.main)
                .sink(receiveValue: { value in
                    let js = "var event = new CustomEvent('customevent', { detail: { data: '\(value)'}}); window.dispatchEvent(event);"
                    webview.evaluateJavaScript(js, completionHandler: { (response, error) in
                        if let error = error {
                            print(error)
                        } else {
                            print("successfully sent a custom event to React app")
                        }
                    })
                })
        }
    }
}

extension SwiftUIWebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "SOME_BRIDGE" {
            delegate?.receivedJsonValueFromWebView(value: message.body as! [String : Any?])
        }
    }
}
