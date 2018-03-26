//
//  BSFilterCollectionViewCell.swift
//  botsocial
//
//  Created by Aamir  on 21/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSFilterCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let nameLabel = UILabel()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.imageView)
        self.addSubview(self.nameLabel)
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = kCornerRadius
        self.nameLabel.textAlignment = .center
        self.nameLabel.adjustsFontSizeToFitWidth = true
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            
        }
        
        self.imageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
    }
}
