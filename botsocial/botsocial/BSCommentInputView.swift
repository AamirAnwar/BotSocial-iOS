//
//  BSCommentInputView.swift
//  
//
//  Created by Aamir  on 23/03/18.
//

import UIKit
protocol BSCommentInputViewDelegate {
    func didTapPostButton()
}
class BSCommentInputView: UIView {
    var delegate:BSCommentInputViewDelegate?
    let commentTextView = UITextView()
    let postButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    let userImageView = UIImageView()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(self.commentTextView)
        self.addSubview(self.userImageView)
        self.addSubview(self.postButton)
        
        self.setTextViewPlaceHolder()
        self.commentTextView.delegate = self
        self.commentTextView.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.postButton.snp.leading).offset(-8)
            make.leading.equalTo(self.userImageView.snp.trailing).offset(8)
            make.bottom.equalToSuperview().inset(kInteritemPadding)
            make.height.equalTo(50)
        }
        
        self.userImageView.layer.cornerRadius = 22
        APIService.sharedInstance.getUserProfileImageURL { (url) in
            if let url = url {
                self.userImageView.pin_setImage(from: url)
            }
        }
        self.userImageView.contentMode = .scaleAspectFill
        self.userImageView.clipsToBounds = true
        self.userImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalTo(self.commentTextView.snp.top)
            make.size.equalTo(44)
        }
        self.postButton.titleLabel?.font = BSFontMediumBold
        self.postButton.setTitleColor(BSColorTextBlack, for: .normal)
        self.postButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        self.postButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.userImageView.snp.centerY)
        }
        
        self.snp.makeConstraints { (make) in
            make.top.equalTo(self.userImageView.snp.top).offset(-kInteritemPadding)
        }
    }
    
    func setTextViewPlaceHolder() {
        self.commentTextView.attributedText = NSMutableAttributedString.init(string: kCommentPlaceholderText, attributes: [.foregroundColor:BSLightGray,.font:BSFontMediumParagraph])
    }
    
    func clearTextViewPlaceHolder() {
        self.commentTextView.attributedText = nil
        self.commentTextView.font = BSFontMediumParagraph
        self.commentTextView.textColor = BSColorTextBlack
    }
 
    @objc func didTapPostButton() {
        self.delegate?.didTapPostButton()
    }
    
}


extension BSCommentInputView:UITextViewDelegate {
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

