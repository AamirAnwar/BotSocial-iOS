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
        self.selectionStyle = .none
        self.storyImageView.contentMode = .scaleAspectFill
        self.storyImageView.clipsToBounds = true
        self.storyImageView.image = #imageLiteral(resourceName: "placeholder_image")
        //self.storyImageView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.contentView.clipsToBounds = true
        
    }
    
    public func setImageURL(_ urlString:String) {
        guard let url = URL(string:urlString) else {
            self.storyImageView.image = #imageLiteral(resourceName: "placeholder_image")
            return
        }
        self.storyImageView.pin_setImage(from: url) { (result) in
//            if let image = result.image {
                // TODO
//                let width = UIScreen.main.bounds.width
//                let height = ((image.size.height/UIScreen.main.scale) * (width/(image.size.width/UIScreen.main.scale)))
//                self.storyImageView.snp.updateConstraints { (make) in
//                    make.height.equalTo(max(200,min(height,400)))
//                }
////                self.delegate?.didUpdateCellHeight()
//                self.layoutIfNeeded()
//            }
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.storyImageView.image = nil
    }
}
