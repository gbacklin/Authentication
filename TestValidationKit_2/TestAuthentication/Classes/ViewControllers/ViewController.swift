//
//  ViewController.swift
//  TestAuthentication
//
//  Created by Gene Backlin on 5/4/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit
import ValidationKit

class ViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var faceIDLabel: UILabel!

    /// The current authentication state.
    var state = AuthenticationState.loggedout {
        // Update the UI on a change.
        didSet {
            loginButton.isHighlighted = state == .loggedin  // The button text changes on highlight.
            stateView.backgroundColor = state == .loggedin ? .green : .red
            
            // FaceID runs right away on evaluation, so you might want to warn the user.
            //  In this app, show a special Face ID prompt if the user is logged out, but
            //  only if the device supports that kind of authentication.
            faceIDLabel.isHidden = (state == AuthenticationState.loggedin) || (!Validator.shared.isFaceId())
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    /// Logs out or attempts to log in when the user taps the button.
    @IBAction func tapButton(_ sender: UIButton) {
        Validator.shared.login {[unowned self] (result, error, state) in
            self.state = state
            if result == false {
                let alertController = Validator.shared.createAlertController(error: error, title: "Login")
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

