//
//  WebViewController.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/28/21.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController {
    private var request: URLRequest
    
    private var webView = WKWebView()
    //MARK: - Setup
    private func setup() {
        view.fill(with: webView)
    }
    
    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        webView.load(request)
        
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    init(request: URLRequest) {
        self.request = request
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
