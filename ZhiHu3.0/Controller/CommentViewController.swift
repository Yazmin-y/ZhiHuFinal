//
//  CommentViewController.swift
//  ZhiHu3.0
//
//  Created by 游奕桁 on 2019/12/8.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import MJRefresh

class CommentViewController: UIViewController {
    lazy var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: view.bounds.height), style: .grouped)
    var comment: LongComment!
    let header = MJRefreshNormalHeader()
    
// MARK: - LifeCircle
    override func loadView() {
        super.loadView()
        loadComment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()

        setRefresh()
    }
    
// MARK: - SetUp-Func
    func loadComment() {
        CommentRequest.getComment(success: { (comment) in
            self.comment = comment
            self.tableView.reloadData()
            self.setUpNavigation()
            print(comment)
        }) { error in
            print("error")
        }
    }
    
    func setUpTableView() {
        tableView.backgroundColor = .white
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
        tableView.contentInset.top = -64
        tableView.clipsToBounds = false
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableView")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    func setUpNavigation() {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = true
        if comment == nil {
            navigationItem.title = "0条评论"
        } else {
            navigationItem.title = "\(comment.comments.count)条评论"
        
        }
    }
    
    func setRefresh() {
           header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
           header.setTitle("正在刷新", for: .pulling)
           header.setTitle("没有更多评论啦", for: .noMoreData)
           self.tableView.mj_header = header
       }
    
    @objc func headerRefresh() {
        loadComment()
        self.tableView.reloadData()
        self.tableView.mj_header?.endRefreshing()
    }
}

// MARK: - TableViewDataSource
extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comment == nil { return 0 } else {
        return comment.comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Comment")
        
        let authorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth - 20, height: 20))
        let contentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth - 20, height: 35))
        let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth - 20, height: 15))
        
        authorLabel.text = comment.comments[indexPath.row].author
        authorLabel.textAlignment = .left
        authorLabel.textColor = .black
        authorLabel.backgroundColor = .clear
        authorLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.equalTo(screenWidth - 20)
        }
        
        contentLabel.text = comment.comments[indexPath.row].content
        contentLabel.textAlignment = .left
        contentLabel.textColor = .black
        contentLabel.backgroundColor = .clear
        contentLabel.numberOfLines = 3
        contentLabel.font = UIFont.preferredFont(forTextStyle: .body)
        cell.contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(10)
            make.left.equalTo(authorLabel.snp.left)
            make.height.equalTo(35)
            make.width.equalTo(screenWidth - 80)
        }
        
        timeLabel.text = String(comment.comments[indexPath.row].time)
        timeLabel.textAlignment = .left
        timeLabel.textColor = .lightGray
        timeLabel.backgroundColor = .clear
        timeLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        cell.contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.equalTo(authorLabel.snp.left)
            make.height.equalTo(15)
            make.width.equalTo(authorLabel.snp.width)
        }
        
        let imgView = UIImageView()
        let imgURL = comment.comments[indexPath.row].avatar
        imgView.setImageUrl(string: imgURL)
        cell.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }

        return cell
    }
    
    
}

// MARK: - TableViewDelegate
extension CommentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
