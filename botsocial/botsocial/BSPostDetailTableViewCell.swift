//
//  BSPostDetailTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSPostDetailTableViewCell: UITableViewCell {
    let postTitleLabel:UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 4
        return label
    }()
    
    let postDateLabel:UILabel = {
        let label = UILabel()
        return label
    }()
 
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var post:BSPost? {
        didSet {
            if let post = post, let authorName = post.authorName {
                let string = NSMutableAttributedString.init(string: "\(authorName)", attributes: [.font:BSFontMediumBold])
                string.append(NSAttributedString.init(string: " \(post.caption ?? "")", attributes: [.font:BSFontMediumParagraph]))
                postTitleLabel.attributedText = string
            }
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.postTitleLabel)
        self.contentView.addSubview(self.postDateLabel)
        self.postTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
//            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
        
        self.postDateLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.postTitleLabel.snp.leading)
            make.trailing.equalTo(self.postTitleLabel.snp.trailing)
            make.top.equalTo(self.postTitleLabel.snp.bottom).offset(0)
            make.bottom.equalToSuperview().inset(2*kInteritemPadding)
        }
    }
}

