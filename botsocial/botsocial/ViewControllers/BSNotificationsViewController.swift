//
//  BSNotificationsViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSNotificationsViewController: BSBaseViewController {
    let kNotifCellReuseID = "BSNotificationTableViewCell"
    var notifications:[BSNotification] = []
    let refreshControl:UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = BSColorTextBlack
        return control
    }()
    var isLoadingNotifications = false
    var handleRef:UInt?
    var notificationSet:Set<String> = Set<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = BSColorTextBlack
        self.navigationItem.title = "Notifications"
        self.tableView.refreshControl = self.refreshControl
        self.tableView.register(BSNotificationTableViewCell.self, forCellReuseIdentifier: kNotifCellReuseID)
        self.tableView.register(BSLoaderTableViewCell.self, forCellReuseIdentifier: kLoadingCellReuseID)
        self.tableView.register(BSEmptyStateTableViewCell.self, forCellReuseIdentifier: kEmptyStateCellReuseID)
        self.refreshControl.addTarget(self, action: #selector(didPromptRefresh), for: UIControlEvents.valueChanged)
        self.observeNotifications()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tabBarItem.badgeValue = nil
    }
    
    func observeNotifications() {
        isLoadingNotifications = true
        notificationSet = Set<String>()
        self.notifications.removeAll()
        APIService.sharedInstance.getNotifications { (notification, handle) in
            self.handleRef = handle
            if let notif = notification, self.notificationSet.contains(notif.id) == false {
                self.notifications.insert(notif, at: 0)
                self.notificationSet.insert(notif.id)
                self.incrementUnreadBadge()
             
            }
            self.refreshControl.endRefreshing()
            self.isLoadingNotifications = false
            self.tableView.reloadData()
            
            
        }
    }
    
    func incrementUnreadBadge() {
        if self.tabBarController?.selectedIndex != 1 {
            self.tabBarItem.badgeColor = UIColor.red.withAlphaComponent(0.8)
            if let v = self.navigationController?.tabBarItem.badgeValue, let value = Int(v) {
                self.navigationController?.tabBarItem.badgeValue = "\(value + 1)"
            }
            else {
                self.navigationController?.tabBarItem.badgeValue = "1"
            }
        }
    }
    
    @objc func didPromptRefresh() {
        self.observeNotifications()
    }
}

extension BSNotificationsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.isLoadingNotifications == false else {return 1}
        guard self.notifications.isEmpty == false else {return 1}
        return self.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.isLoadingNotifications == false else {
            return tableView.dequeueReusableCell(withIdentifier: kLoadingCellReuseID)!
        }
        guard self.notifications.isEmpty == false else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kEmptyStateCellReuseID) as! BSEmptyStateTableViewCell
            cell.titleLabel.text = "No notifications"
            return cell
        }
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: kNotifCellReuseID) as! BSNotificationTableViewCell
        let notification = self.notifications[indexPath.row]
        if let text = notification.text {
            cell.configureWith(authorName:notification.authorName, title: text)
        }
        if let authorID = notification.userID, authorID.isEmpty == false {
            APIService.sharedInstance.getProfilePictureFor(userID: authorID, completion: { (url, handle) in
                self.addHandle(handle)
                if let url = url {
                    cell.userThumbnailImageView.pin_setImage(from: url)
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard self.notifications.isEmpty == false else {return}
        if let postID = self.notifications[indexPath.row].postID {
            APIService.sharedInstance.getPostWith(postID: postID, completion: { (post) in
                if let post = post {
                    let vc = BSPostViewController()
                    vc.post = post
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            
        }
        
    }
}
