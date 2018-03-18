//
//  BSFeedTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit
import PINRemoteImage

class BSFeedTableViewCell: UITableViewCell {
    let storyImageView = UIImageView.init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.storyImageView)
        self.storyImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(460)
        }
        self.storyImageView.contentMode = .scaleAspectFill
        self.storyImageView.clipsToBounds = true
    }
    
    public func setImageURL(_ url:URL) {
        self.storyImageView.pin_setImage(from: url)
        self.layoutIfNeeded()
    }


}
