//
//  BSFilterView.swift
//  botsocial
//
//  Created by Aamir  on 21/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSFilterView: UIView {
    let filterCollectionView:UICollectionView = {
        let layout =  UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    fileprivate let filterNameList = [
        "No Filter",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CILinearToSRGBToneCurve",
        "CISRGBToneCurveToLinear"
    ]
    
    fileprivate let filterDisplayNameList = [
        "Normal",
        "Chrome",
        "Fade",
        "Instant",
        "Mono",
        "Noir",
        "Process",
        "Tonal",
        "Transfer",
        "Tone",
        "Linear"
    ]
    fileprivate var filterIndex = 0
    fileprivate let context = CIContext(options: nil)
    fileprivate var smallImage: UIImage?
    fileprivate var capturedImage: UIImage?
    var capturedImageView:UIImageView? {
        didSet {
            if let image = capturedImageView?.image {
                self.capturedImage = image
                self.smallImage = resizeImage(image: image)
                self.filterCollectionView.reloadData()
            }
            
        }
    }
    let kFilterCellReuseID = "BSFilterCollectionViewCell"
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.filterCollectionView)
        self.filterCollectionView.backgroundColor = UIColor.white
        self.filterCollectionView.register(BSFilterCollectionViewCell.self, forCellWithReuseIdentifier: kFilterCellReuseID)
        self.filterCollectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
    }

}


extension BSFilterView:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 130, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFilterCellReuseID, for: indexPath) as! BSFilterCollectionViewCell
        var filteredImage = smallImage
        if let image = smallImage, indexPath.row != 0 {
            filteredImage = createFilteredImage(filterName: filterNameList[indexPath.row], image: image)
        }
        cell.imageView.image = filteredImage
        cell.nameLabel.text = filterDisplayNameList[indexPath.row]
        updateCellFont()
        return cell
        
    }
    
    func scrollCollectionViewToIndex(itemIndex: Int) {
        let indexPath = IndexPath(item: itemIndex, section: 0)
        self.filterCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func updateCellFont() {
        // update font of selected cell
        if let selectedCell = self.filterCollectionView.cellForItem(at: IndexPath(row: filterIndex, section: 0)) {
                        let cell = selectedCell as! BSFilterCollectionViewCell
                        cell.nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        }
        
        for i in 0...filterNameList.count - 1 {
            if i != filterIndex {
                // update nonselected cell font
                if let unselectedCell = self.filterCollectionView.cellForItem(at: IndexPath(row: i, section: 0)) {
                    if let cell = unselectedCell as? BSFilterCollectionViewCell {
                        cell.nameLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
                    }
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterIndex = indexPath.row
        if filterIndex != 0 {
            applyFilter()
        } else {
            self.capturedImageView?.image = self.capturedImage
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: indexPath.item)
    }
    
}

extension BSFilterView {
    @objc func imageViewDidSwipeLeft() {
        if filterIndex == filterNameList.count - 1 {
            filterIndex = 0
            self.capturedImageView?.image = self.capturedImage
        } else {
            filterIndex += 1
        }
        if filterIndex != 0 {
            applyFilter()
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: filterIndex)
    }
    
    @objc func imageViewDidSwipeRight() {
        if filterIndex == 0 {
            filterIndex = filterNameList.count - 1
        } else {
            filterIndex -= 1
        }
        if filterIndex != 0 {
            applyFilter()
        } else {
            self.capturedImageView?.image = self.capturedImage
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: filterIndex)
    }
    
    func applyFilter() {
        let filterName = filterNameList[filterIndex]
        if let image = self.capturedImage {
            let filteredImage = createFilteredImage(filterName: filterName, image: image)
            self.capturedImageView?.image = filteredImage
        }
    }
    
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!, scale: image.scale, orientation: image.imageOrientation)
        
        return filteredImage
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let ratio: CGFloat = 0.3
        let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

