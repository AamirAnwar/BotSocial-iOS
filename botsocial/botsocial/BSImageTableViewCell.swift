//
//  BSImageTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSImageTableViewCell: UITableViewCell {
    let storyImageView = UIImageView.init()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.storyImageView)
        self.storyImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(400)
        }
        self.storyImageView.contentMode = .scaleAspectFill
        self.storyImageView.clipsToBounds = true
        self.storyImageView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.contentView.clipsToBounds = true
        
    }
    
    public func setImageURL(_ urlString:String) {
        self.storyImageView.pin_setImage(from: URL(string:urlString))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.storyImageView.image = nil
    }
}
