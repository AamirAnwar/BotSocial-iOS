//
//  BSFeedViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit

let kTestImageURL = "https://avatars3.githubusercontent.com/u/12379620?s=460&v=4"

class BSFeedViewController: UIViewController {

    let tableView = UITableView.init(frame: .zero, style: .plain)
    let kFeedCellReuseIdentifier = "Feed_BSFeedTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarItem.image = UIImage.init(named: "feed_tab_icon")
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delaysContentTouches = false
        self.tableView.register(BSFeedTableViewCell.self, forCellReuseIdentifier: self.kFeedCellReuseIdentifier)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension BSFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.kFeedCellReuseIdentifier) as! BSFeedTableViewCell
//        cell.setImageURL(URL(string:kTestImageURL)!)
        return cell
    }
    
}
