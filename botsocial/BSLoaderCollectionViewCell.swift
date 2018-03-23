//
//  BSLoaderCollectionViewCell.swift
//  botsocial
//
//  Created by Aamir  on 23/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSLoaderCollectionViewCell: UICollectionViewCell {
    let loader:UIActivityIndicatorView =  {
        let loader = UIActivityIndicatorView.init()
        loader.activityIndicatorViewStyle = .gray
        return loader
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.loader)
        self.loader.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(20)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
        }
    }
    
    func startLoader() {
        self.loader.startAnimating()
    }
    
    func stopLoader() {
        self.loader.stopAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.loader.startAnimating()
    }
}
