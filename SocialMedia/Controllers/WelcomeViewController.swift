//
//  ViewController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 15/02/21.
//

import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var appNameLabel: CLTypingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appNameLabel.text = K.appName
    }
    
}
