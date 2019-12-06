//
//  ViewController.swift
//  ZhiHu3.0
//
//  Created by 游奕桁 on 2019/12/5.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import AlamofireImage

let screenWidth = UIScreen.main.bounds.width
let screenHeigh = UIScreen.main.bounds.height


var latestURL: URL {
        return URL(string: "https://news-at.zhihu.com/api/4/news/latest")!
}


class ViewController: UIViewController {
    let banner = UIScrollView()
    let tableView = UITableView(frame: CGRect(), style: .grouped)
    var news: LatestNews!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigation()
        setUpBanner()
        setUpTableView()
        loadTopStories()
        // Do any additional setup after loading the view.
    }
   
    
    func setUpNavigation() {
        navigationItem.title = "知乎日报"
        let today = Date()
        let formatter = DateFormatter()
        let dateString = formatter.string(from: today)
        formatter.dateFormat = "MMM dd"
        formatter.locale = Locale.current
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\(dateString)", style: .done, target: self, action: nil)
        navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func setUpBanner() {
        banner.frame = CGRect(x: 0, y: 100, width: screenWidth, height: screenWidth/2)
        let imageView = UIImageView()
//        imageView.af_setImage(withURL: URL(string: ))
        banner.contentSize = imageView.bounds.size
        banner.addSubview(imageView)
        view.addSubview(banner)
        banner.indicatorStyle = .white
        banner.delegate = self
        banner.minimumZoomScale = 0
        banner.maximumZoomScale = 0
        banner.bounces = true
        banner.isPagingEnabled = true
        
    }
    
    func setUpTableView() {
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
        tableView.contentInset.top = -64
        tableView.clipsToBounds = false
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableView")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    func loadTopStories() {
        latestNewsHelper.getLatestNews(success: { news in
            self.news = news
            self.tableView.reloadData()
        }) { (error) in
            print("error")
        }
    }

}

extension ViewController: UIScrollViewDelegate {
    
}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if news == nil {
            return 0
        }
        return news.stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Story") as? StoryCell
        cell?.img = nil
        cell?.configure(for: news.stories[indexPath.row])
        cell?.selectionStyle = .none
        return cell!
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(DetailViewController(), animated: true)
    }
}
