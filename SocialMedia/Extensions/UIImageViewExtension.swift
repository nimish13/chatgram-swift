//
//  UIImageViewExtension.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 24/02/21.
//

import UIKit

extension UIImageView {
    public func maskCircle(with image: UIImage? = nil) {
        self.contentMode = UIView.ContentMode.scaleAspectFill
        self.backgroundColor = UIColor.black
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        if let providedImage = image {
            self.image = providedImage
        }
    }
}
