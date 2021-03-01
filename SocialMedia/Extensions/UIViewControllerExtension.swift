//
//  UIViewControllerExtension.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 23/02/21.
//

import UIKit

extension UIViewController {
    
    func showActivityIndicator(with spinner: SpinnerViewController) {
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }

    func hideActivityIndication(with spinner: SpinnerViewController) {
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
    
    func setProfileImage(for additionalUser: User, imageView: UIImageView) {
        if let imageUrl = additionalUser.profileUrl {
            imageView.maskCircle()
            imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholder"))
            
        } else {
            setImageFromName(user: additionalUser, imageView: imageView)
        }
    }
    
    
    func setImageFromName(user: User, imageView: UIImageView) {
        imageView.setImageForName(user.fullName, backgroundColor: UIColor(hex: user.hexcode), circular: true, textAttributes: nil)
    }
    
}
