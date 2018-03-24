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
    let options = ["Log Out"]
    let headerLabel = UILabel()
    let customNavBar = UIView()
    let titleLabel = UILabel()
    let backButton = UIButton.init(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.customNavBar)
        self.customNavBar.addSubview(self.titleLabel)
        self.customNavBar.addSubview(self.backButton)
        
        self.titleLabel.text = "Settings"
        self.titleLabel.font = BSFontLargeBold
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        self.backButton.setTitle("Back", for: .normal)
        self.backButton.titleLabel?.font = BSFontMediumBold
        self.backButton.setTitleColor(BSColorTextBlack, for: .normal)
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        self.backButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
        self.customNavBar.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.customNavBar.snp.bottom)
        }
        self.tableView.contentInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.headerLabel.text = "Account"
        self.headerLabel.font = BSFontMediumBold
        self.headerLabel.textColor = BSColorTextBlack
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width(), height: 44))
        view.addSubview(self.headerLabel)
        self.headerLabel.frame = CGRect.init(x: kSidePadding, y: 0, width: self.view.width() - 2*kSidePadding, height: 44)
        self.tableView.tableHeaderView = view
        
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
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
