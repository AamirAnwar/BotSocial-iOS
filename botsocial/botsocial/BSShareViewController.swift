//
//  BSShareViewController.swift
//  botsocial
//
//  Created by Aamir  on 21/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import Firebase

let kPlaceholderText = "Write a caption..."
class BSShareViewController: UIViewController, UIGestureRecognizerDelegate {
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
    var isUploading = false {
        didSet {
            if isUploading {
                self.showLoader()
            }
            else {
                self.hideLoader()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        self.contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapView)))
        self.view.addSubview(self.shareButton)
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.loaderOverlayView)
        self.loaderOverlayView.addSubview(self.loader)
        
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
        self.setTextViewPlaceHolder()
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

        
        self.loaderOverlayView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(self.navigationController != nil ? self.navigationController!.navigationBar.height():0.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
        
        self.loader.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
        
    }
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapShareButton() {
        guard self.isUploading == false else {return}
        if let image = self.postImage {
            self.isUploading = true
            self.shareButton.isEnabled = false
            var caption = ""
            if  self.textView.text.isEmpty == false && self.textView.text != kPlaceholderText {
                caption = self.textView.text
            }
            APIService.sharedInstance.createPost(caption: caption, image: image) {
                self.isUploading = false
                self.shareButton.isEnabled = true
                self.presentingViewController?.dismiss(animated: true)
            }
        }
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
            self.loaderOverlayView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(keyboardHeight - tabBarHeight)
            })
        }
    }
    
    @objc func willHideKeyboard() {
        guard self.view.window != nil else {return}
        self.scrollView.contentInset = .zero
        self.loaderOverlayView.snp.updateConstraints({ (make) in
            make.bottom.equalToSuperview()
        })
    }
    
    func setTextViewPlaceHolder() {
        self.textView.attributedText = NSMutableAttributedString.init(string: kPlaceholderText, attributes: [.foregroundColor:BSLightGray,
                                                                                                                           .font:BSFontMediumParagraph
            ])
    }
    func clearTextViewPlaceHolder() {
        self.textView.attributedText = nil
        self.textView.font = BSFontMediumParagraph
        self.textView.textColor = BSColorTextBlack
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
}

extension BSShareViewController:UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.setTextViewPlaceHolder()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.attributedText != nil {
            self.clearTextViewPlaceHolder()
            textView.text = ""
        }
    }
}
