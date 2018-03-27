//
//  BSChatListViewController.swift
//  botsocial
//
//  Created by Aamir  on 25/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSChatListViewController: UIViewController, UIGestureRecognizerDelegate {
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let kNotifCellReuseID = "BSNotificationTableViewCell"
    var isLoadingChats = false
    var chats:[BSChatInstance] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.navigationController?.navigationBar.tintColor = BSColorTextBlack
        self.navigationItem.title = "Messages"
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(BSNotificationTableViewCell.self, forCellReuseIdentifier: kNotifCellReuseID)
        self.tableView.register(BSLoaderTableViewCell.self, forCellReuseIdentifier: kLoadingCellReuseID)
        self.tableView.register(BSEmptyStateTableViewCell.self, forCellReuseIdentifier: "empty_state_cell")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.loadUserChats()
    }
    
    func loadUserChats() {
        guard let _ = APIService.sharedInstance.currentUser else {return}
        self.chats = []
        self.isLoadingChats = true
        APIService.sharedInstance.getUserChats { (chat) in
            self.isLoadingChats = false
            if let chat = chat {
                self.chats.insert(chat, at: 0)
                self.tableView.reloadData()
            }
        }
    }
}


extension BSChatListViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.isLoadingChats == false else {return 1}
        guard self.chats.isEmpty == false else {return 1}
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.isLoadingChats == false else {
            return tableView.dequeueReusableCell(withIdentifier: kLoadingCellReuseID)!
        }
        guard self.chats.isEmpty == false else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_state_cell") as! BSEmptyStateTableViewCell
            cell.titleLabel.text = "No chats yet"
            return cell
        }
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: kNotifCellReuseID) as! BSNotificationTableViewCell
        let chatInstance = self.chats[indexPath.row]
        
        cell.configureWith(authorName:chatInstance.receiver.displayName, title: "")
        
        if let receiverID = chatInstance.receiver.id, receiverID.isEmpty == false {
            APIService.sharedInstance.getProfilePictureFor(userID: receiverID, completion: { (url) in
                if let url = url {
                    cell.userThumbnailImageView.pin_setImage(from: url)
                }
                else {
                    cell.userThumbnailImageView.image = #imageLiteral(resourceName: "placeholder_image")
                }
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard self.chats.isEmpty == false, let user = APIService.sharedInstance.currentUser else {return}
        let chatInstance = self.chats[indexPath.row]
        if let receiver = chatInstance.receiver {
            let vc = BSChatViewController()
            vc.receiver = receiver
            vc.senderId = user.uid
            vc.navigationItem.title = receiver.displayName
            vc.hidesBottomBarWhenPushed = true
            vc.senderDisplayName = user.displayName ?? "Messages"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
  }
}
