//
//  BSImageCollectionViewCell.swift
//  botsocial
//
//  Created by Aamir  on 20/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSImageCollectionViewCell: UICollectionViewCell {
    let storyImageView = UIImageView.init()
    let containerView = UIView()
    var isExpanded = false
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.containerView)
        self.containerView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.containerView.addSubview(self.storyImageView)
        self.containerView.layer.cornerRadius = kCornerRadius
        self.containerView.clipsToBounds = true
        self.containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(1)
        }
        self.storyImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.storyImageView.contentMode = .scaleAspectFill
        self.storyImageView.clipsToBounds = true
        self.contentView.clipsToBounds = true
    }
    
    func setImageURL(_ url:URL) {
        self.storyImageView.pin_setImage(from: url)
    }
    
    func expandImages() {
        guard self.isExpanded == false else {return}
        self.isExpanded = true
        let offsetAmount = 50
        self.storyImageView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(-offsetAmount)
            make.trailing.equalToSuperview().offset(offsetAmount)
            make.top.equalToSuperview().offset(-offsetAmount)
            make.bottom.equalToSuperview().offset(offsetAmount)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.storyImageView.image = nil
    }
}
