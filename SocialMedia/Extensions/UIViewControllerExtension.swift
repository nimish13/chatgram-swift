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
    
}
