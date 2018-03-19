//
//  BSAccountViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSAccountViewController: UIViewController {
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let kUserProfileCellReuseID = "BSUserProfileTableViewCell"
    let kImageCellReuseID = "BSImageCollectionViewCell"
    
    let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        cView.backgroundColor = UIColor.white
        return cView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(BSUserProfileCollectionViewCell.self, forCellWithReuseIdentifier: kUserProfileCellReuseID)
        self.collectionView.register(BSImageCollectionViewCell.self, forCellWithReuseIdentifier: kImageCellReuseID)
    }
}

extension BSAccountViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1: return 24
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize.init(width: self.view.width(), height: 150)
        }
        else {
            return CGSize.init(width: self.view.width()/3, height: 120)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: kUserProfileCellReuseID, for: indexPath)
        case 1:
            return collectionView.dequeueReusableCell(withReuseIdentifier: kImageCellReuseID, for: indexPath)
        default:
            print("Something's wrong")
            return UICollectionViewCell.init()
            
        }
        
    }
}

