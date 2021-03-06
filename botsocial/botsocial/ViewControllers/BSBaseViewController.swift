//
//  BSBaseViewController.swift
//  botsocial
//
//  Created by Aamir  on 27/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSBaseViewController: UIViewController,HandleCollector {
    var tableView = UITableView.init(frame: .zero, style: .plain)
    var handles = Set<UInt>()
    
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
    
    let loaderOverlayView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
        
    }()
    
    let loader:UIActivityIndicatorView =  {
        let view = UIActivityIndicatorView.init()
        view.activityIndicatorViewStyle = .whiteLarge
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.configureTableView()
    }
    
    deinit {
        self.clearHandles()
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
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
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
    
    func showLoader() {
        guard self.loaderOverlayView.isHidden else {return}
        self.loaderOverlayView.alpha = 0
        self.loaderOverlayView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.loaderOverlayView.alpha = 1.0
            self.loader.startAnimating()
        }
    }
    
    func hideLoader() {
        guard self.loaderOverlayView.isHidden == false else {return}
        self.loader.stopAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.loaderOverlayView.alpha = 0
        }) { (_) in
            self.loaderOverlayView.isHidden = true
        }
    }
    
    func willShowKeyboardWith(height:CGFloat) {
        guard self.view.window != nil else {return}
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: height, right: 0)
        })
    }
    
    func willHideKeyboardWith(height:CGFloat) {
        guard self.view.window != nil else {return}
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.contentInset = .zero
        })
    }
}

extension BSBaseViewController:UIGestureRecognizerDelegate {
    func hideNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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

// MARK: Handle Keyboard
extension BSBaseViewController {
    func enableKeyboardListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        
    }
    
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.view.window != nil else {return}
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.willShowKeyboardWith(height: keyboardHeight - self.tabBarHeight)
        }
    }
    
    @objc func willHideKeyboard(notification:NSNotification) {
        guard self.view.window != nil else {return}
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.willHideKeyboardWith(height: keyboardHeight - self.tabBarHeight)
        }
        
    }
}


