//
//  BSCoachmarkView.swift
//  botsocial
//
//  Created by Aamir  on 27/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

let kCoachmarkTitleScrollUp = "Back to top"
let kCoachmarkTitleNewPost = "New post"
let kCoachmarkButtonWidth:CGFloat = 100
let kCoachmarkButtonHeight:CGFloat = 20

protocol BSCoachmarkViewDelegate {
    func didTapCoachmark()
}

class BSCoachmarkView: UIView {
    var delegate:BSCoachmarkViewDelegate?
    var button:UIButton!
    var isVisible = false
    
    static func getCoachmark(title:String,withDelegate delegate:BSCoachmarkViewDelegate) -> BSCoachmarkView {
        let coachmarkButton = UIButton.init(type: .system)
        
        coachmarkButton.titleLabel?.adjustsFontSizeToFitWidth = true
        coachmarkButton.frame = CGRect.init(x: 0, y: 0, width: kCoachmarkButtonWidth, height: kCoachmarkButtonHeight)
        coachmarkButton.setTitle(title, for: .normal)
        coachmarkButton.layer.cornerRadius = kCoachmarkButtonHeight/2
        coachmarkButton.backgroundColor = UIColor.white
        coachmarkButton.titleLabel?.font = BSFontMiniBold
        coachmarkButton.setTitleColor(BSColorTextBlack, for: .normal)
        
        BSCommons.addShadowTo(view:coachmarkButton)
        
        let coachmarkView = BSCoachmarkView()
        coachmarkView.delegate = delegate
        coachmarkView.button = coachmarkButton
        coachmarkView.addSubview(coachmarkButton)
        coachmarkView.frame = coachmarkButton.bounds
        
        coachmarkButton.addTarget(coachmarkView, action: #selector(didTapCoachmark), for: .touchUpInside)
        
        return coachmarkView
    }
    
    @objc func didTapCoachmark() {
        self.delegate?.didTapCoachmark()
    }
    
    func show(withTitle title:String) {
//        guard self.posts.count > 1 && isShowingCoachmark == false else {return}
        guard self.isVisible == false else {return}
        guard let coachmarkSuperview = self.superview else {return}
        self.button.setTitle(title, for: .normal)
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect.init(x: (coachmarkSuperview.width() - self.width())/2, y: coachmarkSuperview.height() - 44 - kInteritemPadding - self.height() - 4, width: self.width(), height: self.height())
        }) { (_) in
            self.isVisible = true
        }
        
    }
    
    func hide() {
        guard isVisible == true,let coachmarkSuperview = self.superview else {return}
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect.init(x: (coachmarkSuperview.width() - self.width())/2, y: coachmarkSuperview.height(), width: self.width(), height: self.height())
        }) { (_) in
            self.isVisible = false
        }
    }

}
