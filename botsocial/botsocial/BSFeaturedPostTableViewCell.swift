//
//  BSFeaturedPostTableViewCell.swift
//  botsocial
//
//  Created by Aamir  on 20/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSFeaturedPostTableViewCell: UITableViewCell {
    let kImageCellReuseID = "BSImageCollectionViewCell"
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = BSFontBigBold
        label.textColor = BSColorTextBlack
        label.text = "Featured Posts"
        label.numberOfLines = 0
        return label
    }()
    var featuredPosts:[BSPost] = []  {
        didSet {
            if featuredPosts.isEmpty {
                self.titleLabel.text = "Tap the camera on the top left to create a post!"
            }
            else {
                self.titleLabel.text = "Featured Posts"
            }
            self.collectionView.reloadData()
        }
    }
    
    let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        let cView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        cView.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        cView.backgroundColor = UIColor.white
        return cView
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        for _ in 0..<25 {
//            featuredPosts += [kTestFeaturedImageURL]
//        }
        self.selectionStyle = .none
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.collectionView)
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(kInteritemPadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
        
        self.collectionView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(kInteritemPadding)
            make.height.equalTo(258)
            make.bottom.equalToSuperview().inset(2*kInteritemPadding)
        }
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.dataSource = self
        self.collectionView.register(BSImageCollectionViewCell.self, forCellWithReuseIdentifier: kImageCellReuseID)
    }

}


extension BSFeaturedPostTableViewCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuredPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 304, height: 248)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kImageCellReuseID, for: indexPath) as! BSImageCollectionViewCell
        if let urlString = featuredPosts[indexPath.row].imageURL, let url = URL(string:urlString) {
            cell.setImageURL(url)
        }
        if indexPath.row == 1 && cell.isExpanded == false {
            let cellFrame = collectionView.convert(cell.frame, to: self.contentView)
            let translationX = cellFrame.origin.x / 5
            cell.storyImageView.transform = CGAffineTransform(translationX: translationX, y: 0)
            cell.layer.transform = animateCell(cellFrame: cellFrame)
        }
        cell.expandImages()
        return cell
        
    }

}


extension BSFeaturedPostTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
        if let collectionView = scrollView as? UICollectionView {
            for cell in collectionView.visibleCells as! [BSImageCollectionViewCell] {
                configure(cell)
            }
        }
    }
    
    func configure(_ cell:BSImageCollectionViewCell) {
        let indexPath = collectionView.indexPath(for: cell)!
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)!
        let cellFrame = collectionView.convert(attributes.frame, to: self.contentView)
        
        let translationX = cellFrame.origin.x / 5
        cell.storyImageView.transform = CGAffineTransform(translationX: translationX, y: 0)
        cell.layer.transform = animateCell(cellFrame: cellFrame)
    }
    
    func animateCell(cellFrame: CGRect) -> CATransform3D {
        let angleFromX = Double((-cellFrame.origin.x) / 10)
        let angle = CGFloat((angleFromX * Double.pi) / 180.0)
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/1000
        let rotation = CATransform3DRotate(transform, angle, 0, 1, 0)
        
        var scaleFromX = (1000 - (cellFrame.origin.x - 200)) / 1000
        let scaleMax: CGFloat = 1.0
        let scaleMin: CGFloat = 0.6
        if scaleFromX > scaleMax {
            scaleFromX = scaleMax
        }
        if scaleFromX < scaleMin {
            scaleFromX = scaleMin
        }
        let scale = CATransform3DScale(CATransform3DIdentity, scaleFromX, scaleFromX, 1)
        
        return CATransform3DConcat(rotation, scale)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

