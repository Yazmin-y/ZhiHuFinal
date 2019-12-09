//
//  DetailViewController.swift
//  ZhiHu3.0
//
//  Created by 游奕桁 on 2019/12/5.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import WebKit
import SnapKit

class DetailViewController: UIViewController {
    var imageHeight: CGFloat = 200
    var webView: WKWebView!
    var toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
    var imgView: UIImageView!

// MARK: - LifeCircle
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeigh), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.backgroundColor = .white
        webView.clipsToBounds = false
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBanner()
        setUpToolBar()
        guard let myURL = URL(string: ViewController.news.stories[ViewController.row].url) else { return  }
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    
// MARK: - SetUp Func
    func setUpBanner() {
        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: imageHeight))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
    }
    
    func setUpToolBar() {
        let commentButton = UIBarButtonItem(title: "查看评论", style: .plain, target: self, action: #selector(pushComment))
        let butGap = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        butGap.width = screenWidth/3 + 15
        let buttons: [UIBarButtonItem] = [butGap ,commentButton]
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.setItems(buttons, animated: true)
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(screenWidth)
            make.height.equalTo(60)
        }
        
    }
    
    @objc func pushComment() {
        navigationController?.pushViewController(CommentViewController(), animated: true)
    }
}

// MARK: - Delegates
extension DetailViewController: UIScrollViewDelegate {

}

extension DetailViewController: WKUIDelegate {
    
}

extension DetailViewController: UIToolbarDelegate {
    
}


