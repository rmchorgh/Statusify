//
//  WebView.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/2/23.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    typealias NSViewType = WKWebView
    
    let webView: WKWebView
    
    init() {
        webView = WKWebView(frame: .zero)
        webView.load(URLRequest(url: URL(string: "http://localhost:3000")!))
    }
    
    func makeNSView(context: Context) -> WKWebView {
        webView
    }
    
    func updateNSView(_ uiView: WKWebView, context: Context) {
    }
}

class WebViewWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(
                x: 800,
                y: 800,
                width: 480,
                height: 300
            ),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )
        makeKeyAndOrderFront(nil)
        isReleasedWhenClosed = false
        styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
        title = "Spotify API Key"
        contentView = NSHostingView(rootView: WebView())
    }
}
