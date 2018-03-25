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
    var user:BSUser? {
        didSet {
            self.navigationItem.title = user?.displayName ?? APIService.sharedInstance.currentUser?.displayName
            if let user = user,let currentUser = APIService.sharedInstance.currentUser, currentUser.uid != user.id {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "chat_icon"), style: .plain, target: self, action: #selector(didTapChatButton))
                self.navigationItem.rightBarButtonItem?.tintColor = BSColorTextBlack
            }
            else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        cView.backgroundColor = UIColor.white
        return cView
    }()
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.isLoading = true
        if let user = self.user {
            APIService.sharedInstance.getPostsWith(userID: user.id, completion: { (post) in
                self.isLoading = false
                if let post = post {
                    self.userPosts.insert(post, at: 0)
                }
                self.collectionView.reloadData()
            })
            
        }
        else {
            APIService.sharedInstance.getUserPosts { (post) in
                self.isLoading = false
                if let post = post {
                    self.userPosts.insert(post, at: 0)
                }
                self.collectionView.reloadData()
            }
        }
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(BSLoaderCollectionViewCell.self, forCellWithReuseIdentifier: "loader_cell")
        self.collectionView.register(BSEmptyStateCollectionViewCell.self, forCellWithReuseIdentifier: "empty_state_cell")
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
        case 1:
            guard self.isLoading == false else {return 1}
            guard self.userPosts.isEmpty == false else {return 1}
            return userPosts.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize.init(width: self.view.width(), height: 150)
        }
        else {
            guard self.isLoading == false else {return CGSize.init(width: self.view.width(), height: 20)}
            guard self.userPosts.isEmpty == false else {return CGSize.init(width: self.view.width(), height: 50)}
            return CGSize.init(width: self.view.width()/3, height: 120)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kUserProfileCellReuseID, for: indexPath) as! BSUserProfileCollectionViewCell
            cell.delegate = self
            cell.configureWithUser(user: self.user)
            if let _ = self.user {
                cell.settingsButton.isHidden = true
            }
            return cell
        case 1:
            guard self.isLoading == false else {return collectionView.dequeueReusableCell(withReuseIdentifier: "loader_cell", for: indexPath)}
            guard self.userPosts.isEmpty == false else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "empty_state_cell", for: indexPath) as! BSEmptyStateCollectionViewCell
                cell.titleLabel.text = "No posts yet"
                return cell
                
            }
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
            guard self.userPosts.isEmpty == false else {return}
            let vc = BSPostViewController()
            vc.post = userPosts[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func didTapChatButton() {
        guard let user = APIService.sharedInstance.currentUser, let receiver = self.user else {
            return
        }
        let vc = BSChatViewController()
        vc.receiverID = receiver.id
        vc.senderId = user.uid
        vc.navigationItem.title = receiver.displayName
        vc.hidesBottomBarWhenPushed = true
        vc.senderDisplayName = user.displayName ?? "Messages"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BSAccountViewController:BSUserProfileCollectionViewCellDelegate {
    func didTapSettingsButton() {
        let vc = BSSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapUserProfileThumb() {
        guard self.user == nil else {return}
        let vc = BSCameraViewController()
        vc.flowType = .ProfilePicture
        let navVC = UINavigationController.init(rootViewController: vc)
        self.present(navVC, animated: true)
    }
}

