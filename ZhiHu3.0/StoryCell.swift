//
//  StoryCell.swift
//  ZhiHu3.0
//
//  Created by 游奕桁 on 2019/12/5.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import AlamofireImage

class StoryCell: UITableViewCell {
    var img: UIImageView!
    var titleLabel: UILabel!
    var imgURL: URL {
        return URL(string: story.image!)!
    }
    var story: Story! {
        didSet {
            self.titleLabel.text = story.title
            self.img.af_setImage(withURL: imgURL)
            self.addSubview(titleLabel)
            self.addSubview(img)
        }
        
    }
    func configure(for story: Story) {
        self.story = story
    }
}
