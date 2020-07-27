//
//  ViewController.swift
//  TerstMyFramework
//
//  Created by Gene Backlin on 7/27/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit
import ValidationKit

let SHOW_SUCCESS_SEGUE_ID = "ShowSuccess"

class ViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var faceIDLabel: UILabel!

    /// The current authentication state.
    var state = AuthenticationState.loggedout {
        // Update the UI on a change.
        didSet {
            loginButton.isHighlighted = state == .loggedin  // The button text changes on highlight.
            
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
    
    // MARK: - IBAction
    
    /// Logs out or attempts to log in when the user taps the button.
    @IBAction func tapButton(_ sender: UIButton) {
        Validator.shared.login {[unowned self] (result, error, state) in
            self.state = state
            if result == false {
                let alertController = Validator.shared.createAlertController(error: error, title: "Login")
                self.present(alertController, animated: true, completion: nil)
            } else {
                if state == .loggedin {
                    self.performSegue(withIdentifier: SHOW_SUCCESS_SEGUE_ID, sender: self)
                }
            }
        }
    }
    
    @IBAction func unwindToLogout(segue: UIStoryboardSegue) {
        state = .loggedout
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SHOW_SUCCESS_SEGUE_ID {
            let controller: SuccessViewController = segue.destination as! SuccessViewController
            controller.isLoggedIn = true
        }
    }

}

