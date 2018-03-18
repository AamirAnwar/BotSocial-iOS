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
        label.text = "aamiranwar this is my first post"
        return label
    }()
    
    let postDateLabel:UILabel = {
        let label = UILabel()
        label.text = "1 day ago"
        return label
    }()
 
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            make.top.equalTo(self.postTitleLabel.snp.bottom).offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
    }
}
