//
//  BSSettingsViewController.swift
//  botsocial
//
//  Created by Aamir  on 23/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import Firebase

class BSSettingsViewController: UIViewController,UIGestureRecognizerDelegate {
    let tableView = UITableView.init(frame: .zero, style: .plain)
    let options = ["Logout"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
}

extension BSSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = BSFontMediumParagraph
        cell.textLabel?.textColor = BSColorTextBlack
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.showLogoutAlert()
        default:
            print()
        }
    }
    func showLogoutAlert() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let logOutAction = UIAlertAction.init(title: "Logout", style: .destructive) { (action) in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                
                
                do {
                    try Auth.auth().signOut()
                    BSCommons.showLoginPage(delegate: appDelegate)
                }
                catch {
                    
                }
            }
            
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancel)
        present(alertController, animated:true)
    }
}
