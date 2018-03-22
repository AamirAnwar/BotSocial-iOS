//
//  BSAccountViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSAccountViewController: UIViewController, UIGestureRecognizerDelegate {
    let kUserProfileCellReuseID = "BSUserProfileCollectionViewCell"
    let kImageCellReuseID = "BSImageCollectionViewCell"
    var userPosts = [BSPost]()
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
//        for _ in 0..<30 {
//            userImages += [kTestImageURL]
//        }
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        APIService.sharedInstance.getUserPosts { (post) in
            if let post = post {
                self.userPosts.insert(post, at: 0)
                self.collectionView.reloadData()
            }
            
        }
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
        case 1: return userPosts.count
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kUserProfileCellReuseID, for: indexPath) as! BSUserProfileCollectionViewCell
            cell.delegate = self
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kImageCellReuseID, for: indexPath) as! BSImageCollectionViewCell
            if let url = URL(string:userPosts[indexPath.row].imageURL) {
                cell.setImageURL(url)
            }
            return cell
        default:
            print("Something's wrong")
            return UICollectionViewCell.init()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let vc = BSPostViewController()
            vc.post = userPosts[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension BSAccountViewController:BSUserProfileCollectionViewCellDelegate {
    func didTapSettingsButton() {
        let vc = BSSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapUserProfileThumb() {
        let vc = BSCameraViewController()
        vc.flowType = .ProfilePicture
        let navVC = UINavigationController.init(rootViewController: vc)
        self.present(navVC, animated: true)
    }
}

