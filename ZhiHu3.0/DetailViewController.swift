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

class DetailViewController: UIViewController {
    var imageHeight: CGFloat = 200
    var webView: WKWebView!
    var toolBar: UIToolbar!
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
    var story: Story! {
        didSet {
            self.navigationItem.title = story.title
            requestContent()
        }
    }
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeigh), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.backgroundColor = .white
        webView.addSubview(imgView)
        webView.clipsToBounds = false

        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBanner()
        guard let myURL = URL(string: story.url) else { return  }
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    
    func setUpBanner() {
        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: imageHeight))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
    }
    
    func requestContent() {
        request(story.url, method: .get).responseJSON { (response) in
            switch response.result {
            
            case .success(let json as [String: Any]):
                guard let image = json["image"] as? String, let imageURL = URL(string: image), let body = json["body"] as? String, let css = json["css"] as? [String]
                    else {
                        return
                }
                
                self.imgView.af_setImage(withURL: imageURL)
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
    
}
extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
    }
}
extension DetailViewController: WKUIDelegate {
    
}
