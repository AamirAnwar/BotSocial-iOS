//
//  BSEmptyStateCollectionViewCell.swift
//  botsocial
//
//  Created by Aamir  on 24/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSEmptyStateCollectionViewCell: UICollectionViewCell {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
        
    }
}
