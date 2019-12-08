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
    var navigationBarBackgroundImg: UIView? {
        return (navigationController?.navigationBar.subviews.first)
    }
    var imgView: UIImageView!
    var webScrollView: UIScrollView {
        guard let scrollView = webView.subviews[0] as? UIScrollView else {
            fatalError()
        }
        return scrollView
    }
    
//    var story: Story! {
//        didSet {
//            self.navigationItem.title = story.title
//            requestContent()
//        }
//    }
    
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
        print(myURL)
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    
    func setUpBanner() {
        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: imageHeight))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
    }
    
    func requestContent() {
        request(ViewController.news.stories[ViewController.row].url, method: .get).responseJSON { (response) in
            switch response.result {
            
            case .success(let json as [String: Any]):
                guard let body = json["body"] as? String, let css = json["css"] as? [String]
                    else {
                        return
                }
                let html = self.concatHTML(css: css, body: body)
                self.webView.loadHTMLString(html, baseURL: nil)
            
            case .failure(_):
                fatalError()
            
            @unknown default:
                break;
            }
        }
    }
    
    func concatHTML(css: [String], body: String) -> String {
        var html = "<html>"
        html += "<head>"
        css.forEach { html += "<link rel=\"stylesheet\" href=\($0)>"}
        html += "<style>img{max-width:320px !important;}</style>"
        html += "</head>"
        
        html += "<body>"
        html += body
        html += "</body>"
        
        html += "</html>"
        
        return html
    }
    
    func setUpToolBar() {
        let commentButton = UIBarButtonItem(title: "评论", style: .plain, target: self, action: #selector(pushComment))
        let butGap = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        butGap.width = screenWidth/3 + 25
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
extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
    }
}
extension DetailViewController: WKUIDelegate {
    
}

extension DetailViewController: UIToolbarDelegate {
    
}


