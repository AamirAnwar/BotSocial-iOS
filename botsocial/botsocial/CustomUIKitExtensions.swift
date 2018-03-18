//
//  CustomUIKitExtensions.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func originX() -> CGFloat {
        return self.frame.origin.x
    }
    func originY() -> CGFloat {
        return self.frame.origin.y
    }
    
    func width() -> CGFloat {
        return self.frame.size.width
    }
    
    func height() -> CGFloat {
        return self.frame.size.height
    }
    
    func setX(_ x:CGFloat) {
        self.frame = CGRect.init(x: x, y: self.originY(), width: self.width(), height: self.height())
    }
    
    func setY(_ y:CGFloat) {
        self.frame = CGRect.init(x: self.originX(), y: y, width: self.width(), height: self.height())
    }
    
    func setWidth(_ width:CGFloat) {
        self.frame = CGRect.init(x: self.originX(), y: self.originY(), width: width, height: self.height())
    }
    
    func setHeight(_ height:CGFloat) {
        self.frame = CGRect.init(x: self.originX(), y: self.originY(), width: self.width(), height: height)
    }
    
    func bottom() -> CGFloat {
        return self.originY() + self.height()
    }
}

//extension UIImageView {
//    func setImage(WithURL url:String) {
//        guard let _ = URL(string:url) else {return}
//        APIService.sharedService.request(.imageURL(urlString: url)) { (result) in
//            switch result {
//            case .failure(let error):
//                print("\(error.localizedDescription)")
//            case .success(let response):
//                DispatchQueue.main.async {
//                    self.image = UIImage(data:response.data)
//                }
//            }
//        }
//    }
//}

extension UIDevice {
    var isiPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}

extension UITableViewCell {
    func showBottomPaddedSeparator() {
        let separator = BSSeparator.separator
        self.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
        }
    }
}

extension UIButton {
    static func getRoundedRectButon(withTitle title:String = "") -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
//        button.backgroundColor = CustomColorMainTheme
        button.layer.cornerRadius = kCornerRadius
//        button.titleLabel?.font = CustomFontButtonTitle
        return button
    }
}
