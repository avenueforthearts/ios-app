//
//  MapController.swift
//  AvenueForTheArts
//
//  Created by Chris Carr on 11/4/17.
//  Copyright © 2017 MichiganLabs. All rights reserved.
//

import UIKit
import WebKit

class MapController: UIViewController {

    let MapURL = "https://www.google.com/maps/d/u/0/viewer?mid=1qx2B4eYIFcgWSOJKGsaKDoV0Z44&ll=42.96264625711024%2C-85.6686170667308&z=14"
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    private var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initWebView()
        if let mapURL = URL(string: MapURL) {
            self.webview.load(
                URLRequest(url: mapURL, timeoutInterval: 25.0)
            )
        }

    }

    private func initWebView() {
        let config = WKWebViewConfiguration()

        self.webview = WKWebView(frame: .zero, configuration: config)
        self.webview.backgroundColor = .clear
        self.webview.navigationDelegate = self
//        self.webview.scrollView.delegate = self
        self.webview.pinToEdges(of: self.containerView)
    }
}

extension MapController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.statusLabel.isHidden = true
    }
}
