//
//  BSBaseViewController.swift
//  botsocial
//
//  Created by Aamir  on 27/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSBaseViewController: UIViewController {
    var tableView = UITableView.init(frame: .zero, style: .plain)
    private(set) var coachmark:BSCoachmarkView?
    var shouldShowCoachmark = false {
        didSet {
            self.configureCoachmarkButton()
        }
    }
    var isShowingCoachmark = false
    var tableDataSource:UITableViewDataSource? {
        didSet {
            self.tableView.dataSource = tableDataSource
        }
    }
    var tableDelegate:UITableViewDelegate? {
        didSet {
            self.tableView.delegate = tableDelegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.configureTableView()
    }
    
    public func configureTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.separatorStyle = .none
        self.tableView.delaysContentTouches = false
        self.tableView.register(BSLoaderTableViewCell.self, forCellReuseIdentifier: kLoadingCellReuseID)
        self.tableView.register(BSFeaturedPostTableViewCell.self, forCellReuseIdentifier: kFeaturedCellReuseID)
        self.tableView.register(BSFeedTableViewCell.self, forCellReuseIdentifier: kFeedCellReuseIdentifier)
        self.tableView.register(BSUserSnippetTableViewCell.self, forCellReuseIdentifier: kFeedUserSnippetCellReuseID)
        self.tableView.register(BSImageTableViewCell.self, forCellReuseIdentifier: kFeedImageCellReuseID)
        self.tableView.register(BSFeedActionsTableViewCell.self, forCellReuseIdentifier: kFeedActionsCellReuseID)
        self.tableView.register(BSPostDetailTableViewCell.self, forCellReuseIdentifier: kFeedPostInfoCellReuseID)
        self.tableView.register(BSAddCommentTableViewCell.self, forCellReuseIdentifier: kFeedCommentInfoCellReuseID)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func configureCoachmarkButton() {
        if self.shouldShowCoachmark {
            self.coachmark = BSCoachmarkView.getCoachmark(title: "Back to top", withDelegate: self)
            self.view.addSubview(self.coachmark!)
        }
        else {
            self.coachmark?.removeFromSuperview()
            self.coachmark = nil
        }
        
    }
}

extension BSBaseViewController:BSCoachmarkViewDelegate {
    
    @objc func didTapCoachmark() {
        self.tableView.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: 1, height: 1), animated: true)
        self.coachmark?.hide()
    }
    
}

extension BSBaseViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: Helper methods
extension BSBaseViewController {
    var navBarHeight:CGFloat {
        get {
            if let navBar = self.navigationController?.navigationBar {
                return navBar.height()
            }
            return 0.0
        }
    }
    
    var tabBarHeight:CGFloat {
        get {
            if let tabBar = self.tabBarController?.tabBar {
                return tabBar.height()
            }
            return 0.0
        }
    }
    
}

