//
//  ViewController.swift
//  ZhiHu3.0
//
//  Created by 游奕桁 on 2019/12/5.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import AlamofireImage
import SnapKit
import MJRefresh

let screenWidth = UIScreen.main.bounds.width
let screenHeigh = UIScreen.main.bounds.height
let imageWidth = 80
let imageHeight = 70
var storyImg: [String] = []
var imageView: [UIImageView] = []
let header = MJRefreshNormalHeader()
let footer = MJRefreshAutoNormalFooter()


class ViewController: UIViewController {
    
    let banner = UIScrollView()
    lazy var tableView = UITableView(frame: CGRect(x: 0, y: 512, width: screenWidth, height: screenHeigh), style: .grouped)
    static var news: LatestNews!
    static var row: Int!
  
// MARK: - LifeCircle
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStories()
        
        setRefresh()
        
        setUpNavigation()
        
        setUpTableView()
        
    }
    
// MARK: - SetUp-Func
    
// MARK: Load
    func setRefresh() {
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        header.setTitle("正在刷新", for: .pulling)
        header.setTitle("刷新完成", for: .noMoreData)
        self.tableView.mj_header = header
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        footer.setTitle("正在加载", for: .pulling)
        footer.setTitle("没有更多新闻啦", for: .noMoreData)
        self.tableView.mj_footer = footer
    }
    
    func loadStories() {
          latestNewsHelper.getLatestNews(success: { news in
              ViewController.self.news = news
            self.tableView.reloadData()
            self.setUpBanner()
          }) { error in
              print("error")
          }
         
          }
    
// MARK: Navigation
    func setUpNavigation() {
        navigationItem.title = "知乎日报"
        let today = Date()
        let hour = DateFormatter()
        hour.dateFormat = "HH"
        hour.locale = Locale.current
        let timeString = hour.string(from: today)
        let timeInt = Int(timeString)
        
        if let time = timeInt {
            switch time {
            case 0...4:
                navigationItem.title = "不要熬夜"
            case 5...10:
                navigationItem.title = "早上好"
            case 11...13:
                navigationItem.title = "中午好"
            case 14...18:
                navigationItem.title = "下午好"
            case 19...23:
                navigationItem.title = "晚上好"
            default:
                break
            }
        }
    
        let dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM dd"
        let dateString = formatter.string(from: today)
        
        dateLabel.text = "\(dateString)"
        dateLabel.textColor = .black
        dateLabel.backgroundColor = .clear
        dateLabel.numberOfLines = 2
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dateLabel)
        navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
//    MARK: Banner
    func setUpBanner() {
        var img: [UIImageView] = []
        
        banner.frame = CGRect(x: 0, y: 80, width: screenWidth, height: screenWidth - 10)
        banner.contentSize = CGSize(width: screenWidth * 5, height: screenWidth - 10)
        
        view.addSubview(banner)
        
        if ViewController.news != nil {
        for i in 0..<ViewController.news.topStories.count {
        if let imgURLString = ViewController.news.topStories[i].image {
            let bannerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 60))
            bannerLabel.numberOfLines = 1
            bannerLabel.text = ViewController.news.topStories[i].title
            bannerLabel.textAlignment = .justified
            bannerLabel.backgroundColor = .lightText
            bannerLabel.textColor = .black
            bannerLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            
            let detailLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 20))
            detailLabel.numberOfLines = 1
            detailLabel.text = ViewController.news.topStories[i].hint
            detailLabel.textAlignment = .left
            detailLabel.backgroundColor = .clear
            detailLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
            
            let image = UIImageView(frame: CGRect(x: screenWidth * CGFloat(i), y: 0, width: screenWidth, height: screenWidth - 10))
            image.setImageUrl(string: imgURLString)
            image.addSubview(bannerLabel)
            bannerLabel.addSubview(detailLabel)
            bannerLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.width.equalTo(screenWidth)
                make.height.equalTo(60)
            }
            
            detailLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-5)
                make.left.equalToSuperview()
                make.height.equalTo(20)
                make.width.equalToSuperview()
            }
            img.append(image)
        }
        }
            
        }        
        
        banner.indicatorStyle = .white
        banner.delegate = self
        banner.minimumZoomScale = 0
        banner.maximumZoomScale = 0
        banner.bounces = true
        banner.isPagingEnabled = true
        
        for i in 0..<ViewController.news.topStories.count{
            banner.addSubview(img[i])
        }
      
    }
    
// MARK: TableView
    func setUpTableView() {
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
        tableView.contentInset.top = -64
        tableView.clipsToBounds = false
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableView")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        view.addSubview(tableView)
    }
    
   
}

// MARK: - ScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    
}

// MARK: - TableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ViewController.news == nil {
            return 0
        }
        return ViewController.news.stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Story")
        cell.textLabel?.text = ViewController.news.stories[indexPath.row].title
        cell.detailTextLabel?.text = ViewController.news.stories[indexPath.row].hint
        cell.detailTextLabel?.textColor = .black
        
        let imgView = UIImageView()
        if ViewController.news == nil {
            loadStories()
        }
        
        let imgURL = ViewController.news.stories[indexPath.row].images?[0]
        imgView.setImageUrl(string: imgURL)
        cell.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(imageWidth)
            make.height.equalTo(imageHeight)
        }

        let detailLabel = UILabel()
        detailLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        detailLabel.text = ViewController.news.stories[indexPath.row].hint
        detailLabel.textAlignment = .left
        detailLabel.textColor = .lightGray
        cell.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(screenWidth)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - TableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(DetailViewController(), animated: true)
        ViewController.row = indexPath.row
    }
}

// MARK: - RefreshFunc
extension ViewController {
    @objc func headerRefresh() {
        loadStories()
        self.tableView.reloadData()
        self.banner.reloadInputViews()
        self.tableView.mj_header?.endRefreshing()
    }
    
    @objc func footerRefresh() {
        self.tableView.reloadData()
        self.banner.reloadInputViews()
        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
    }
}
