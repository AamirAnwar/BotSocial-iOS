//
//  BSLoginViewController.swift
//  botsocial
//
//  Created by Aamir  on 23/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class BSLoginViewController: FUIAuthPickerViewController {
    let kImageCellReuseID = "BSImageCollectionViewCell"
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = BSFontBigBold
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = BSColorTextBlack
        label.text = "Welcome\n\nSign up or Log in to proceed"
        return label
    }()
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
    var stockImages:[String] = []
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, authUI: FUIAuth) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, authUI: authUI)
        self.view.backgroundColor = UIColor.white
        for _ in 0..<25 {
            stockImages += [kTestFeaturedImageURL]
        }
        self.navigationItem.title = nil
        self.navigationItem.leftBarButtonItem = nil
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.bottom.equalTo(self.collectionView.snp.top).offset(-kInteritemPadding)
        }
        self.collectionView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(258)
        }
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.dataSource = self
        self.collectionView.register(BSImageCollectionViewCell.self, forCellWithReuseIdentifier: kImageCellReuseID)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}


extension BSLoginViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stockImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 304, height: 248)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kImageCellReuseID, for: indexPath) as! BSImageCollectionViewCell
        let urlString = self.stockImages[indexPath.row]
        if let url = URL(string:urlString) {
            cell.setImageURL(url)
        }
        if indexPath.row == 1 && cell.isExpanded == false {
            let cellFrame = collectionView.convert(cell.frame, to: self.view)
            let translationX = cellFrame.origin.x / 5
            cell.storyImageView.transform = CGAffineTransform(translationX: translationX, y: 0)
            cell.layer.transform = animateCell(cellFrame: cellFrame)
        }
        cell.expandImages()
        return cell
    }
}


extension BSLoginViewController: UIScrollViewDelegate {
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
        let cellFrame = collectionView.convert(attributes.frame, to: self.view)
        
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
}

