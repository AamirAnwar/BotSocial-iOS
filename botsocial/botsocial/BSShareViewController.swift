//
//  BSShareViewController.swift
//  botsocial
//
//  Created by Aamir  on 21/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
let kPlaceholderText = "Write a caption..."
class BSShareViewController: UIViewController, UIGestureRecognizerDelegate {
    var postImage:UIImage? {
        didSet {
            self.postImageView.image = postImage
        }
    }
    let postImageView = UIImageView()
    let textView:UITextView = UITextView()
    let scrollView = UIScrollView()
    let shareButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    let backButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        self.contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapView)))
        self.view.addSubview(self.shareButton)
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        self.contentView.addSubview(self.postImageView)
        self.contentView.addSubview(self.textView)
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.interactivePopGestureRecognizer?
            .delegate = self
        self.scrollView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.backButton.snp.bottom).offset(kInteritemPadding)
        }
        
        self.contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        
        // Back button
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        self.backButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(2*kInteritemPadding)
        }
        
        // Share button
        self.shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        self.shareButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalToSuperview().offset(2*kInteritemPadding)
        }
        
        self.textView.delegate = self
        self.textView.text = kPlaceholderText
        self.textView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.height.equalTo(100)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalTo(self.postImageView.snp.bottom).offset(kInteritemPadding)
        }
        
        self.postImageView.contentMode = .scaleAspectFill
        self.postImageView.clipsToBounds = true
        self.postImageView.layer.cornerRadius = kCornerRadius
        self.postImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(2*kInteritemPadding)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.height.equalTo(300)
//            make.bottom.greaterThanOrEqualToSuperview().inset(2*kInteritemPadding)
        }
        
    }
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func didTapShareButton() {
        
    }
    @objc func didTapView() {
        self.contentView.endEditing(true)
    }
    
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.view.window != nil else {return}
        
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            var tabBarHeight:CGFloat = 0.0
            if let tabbar = self.tabBarController?.tabBar {
                tabBarHeight = tabbar.height()
            }
            self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight - tabBarHeight, right: 0)
            
        }
    }
    
    @objc func willHideKeyboard() {
        guard self.view.window != nil else {return}
        self.scrollView.contentInset = .zero
    }
}

extension BSShareViewController:UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == kPlaceholderText {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = kPlaceholderText
        }
    }
}