//
//  BSPostViewController.swift
//  botsocial
//
//  Created by Aamir  on 20/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSPostViewController: UITableViewController, UIGestureRecognizerDelegate {
    let kFeedImageCellReuseID = "BSImageTableViewCell"
    let kFeedUserSnippetCellReuseID = "BSUserSnippetTableViewCell"
    let kFeedActionsCellReuseID = "BSFeedActionsTableViewCell"
    let kFeedPostInfoCellReuseID = "BSPostDetailTableViewCell"
    let kFeedCommentInfoCellReuseID = "BSAddCommentTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(BSUserSnippetTableViewCell.self, forCellReuseIdentifier: kFeedUserSnippetCellReuseID)
        self.tableView.register(BSImageTableViewCell.self, forCellReuseIdentifier: kFeedImageCellReuseID)
        self.tableView.register(BSFeedActionsTableViewCell.self, forCellReuseIdentifier: kFeedActionsCellReuseID)
        self.tableView.register(BSPostDetailTableViewCell.self, forCellReuseIdentifier: kFeedPostInfoCellReuseID)
        self.tableView.register(BSAddCommentTableViewCell.self, forCellReuseIdentifier: kFeedCommentInfoCellReuseID)
        self.tableView.delaysContentTouches = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: kFeedUserSnippetCellReuseID)!
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: kFeedImageCellReuseID)!
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: kFeedActionsCellReuseID)!
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: kFeedPostInfoCellReuseID)!
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: kFeedCommentInfoCellReuseID)!
        default:
            return UITableViewCell()
        }
    
    }
}


