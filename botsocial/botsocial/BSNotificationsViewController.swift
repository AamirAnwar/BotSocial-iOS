//
//  BSNotificationsViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSNotificationsViewController: UIViewController, UIGestureRecognizerDelegate {
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let kNotifCellReuseID = "BSNotificationTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(BSNotificationTableViewCell.self, forCellReuseIdentifier: kNotifCellReuseID)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
}

extension BSNotificationsViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: kNotifCellReuseID)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(BSPostViewController(), animated: true)
    }
}
