//
//  WebViewController.swift
//  NewsNLP
//
//  Created by David Ilenwabor on 17/04/2019.
//  Copyright © 2019 Demistry. All rights reserved.
//

import UIKit
import WebKit
import JGProgressHUD

class WebViewController: UIViewController, WKNavigationDelegate{

    
    @IBOutlet weak var webView: WKWebView!
    private var hud : JGProgressHUD?
    var newsObject : ArticleObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false //to show navigation bar
        
        //navBarItem.title = sponsor.name
        
        webView.navigationDelegate = self
        let myURL = newsObject!.url
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        hud = ProgressIndicator.showProgress(on: self.view, with: "Loading website...")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hud?.dismiss()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hud?.dismiss()
        AlertDisplay.showAlert(withTitle: "NEWS", forMessage: error.localizedDescription, onViewController: self)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hud?.dismiss()
        AlertDisplay.showAlert(withTitle: "NEWS", forMessage: error.localizedDescription, onViewController: self)
    }
}
