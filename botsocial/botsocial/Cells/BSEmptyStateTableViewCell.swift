//
//  BSEmptyStateTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 24/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSEmptyStateTableViewCell: UITableViewCell {
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = BSFontBigBold
        label.textColor = BSColorTextBlack
        label.text = "Nothing here"
        return label
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
        
    }
}
