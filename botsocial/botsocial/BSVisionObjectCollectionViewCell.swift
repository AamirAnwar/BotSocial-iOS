//
//  BSVisionObjectCollectionViewCell.swift
//  botsocial
//
//  Created by Aamir  on 23/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSVisionObjectCollectionViewCell: UICollectionViewCell {
    let titleLabel = UILabel()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.textColor = UIColor.black
        let padding:CGFloat = 4
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.top.equalToSuperview().offset(padding)
            make.bottom.equalToSuperview().inset(padding)
        }
    }
}
