//
//  GlobalUtility.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 16/02/21.
//

import UIKit

struct GlobalUtility {
    
    static func showErrorAlert(error: Error, vc: UIViewController) {
        var errorMessage: String?
        if let err = error as? RuntimeError {
            errorMessage = err.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func switchController(identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: identifier)

        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller)
    }
    
    static func randomHexCode(length: Int = 6) -> String{
        let possibleValues = ["1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"];
        var hexValue = "#"
        for _ in 0..<length {
            hexValue += possibleValues.randomElement()!
        }
        return hexValue
    }    
}
