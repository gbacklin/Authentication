//
//  Validator.swift
//  ValidationKit
//
//  Created by Gene Backlin on 7/27/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

#if os(iOS)
    import UIKit
#endif
import LocalAuthentication

/// The available states of being logged in or not.
public enum AuthenticationState {
    case loggedin
    case loggedout
}

public class Validator: NSObject {
    public static var shared = Validator()
    
    var state = AuthenticationState.loggedout
    var context = LAContext()

    override init() {
        super.init()
        // The biometryType, which affects this app's UI when state changes, is only meaningful
        //  after running canEvaluatePolicy. But make sure not to run this test from inside a
        //  policy evaluation callback (for example, don't put next line in the state's didSet
        //  method, which is triggered as a result of the state change made in the callback),
        //  because that might result in deadlock.
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        
        // Set the initial app state. This impacts the initial state of the UI as well.
        state = .loggedout
    }
    
    public func login(completion: ((Bool, Error?, AuthenticationState) -> Void)? = nil) {
        if state == .loggedin {
            // Log out immediately.
            state = .loggedout
            completion!(true, nil, state)
        } else {
            // Get a fresh context for each login. If you use the same context on multiple attempts
            //  (by commenting out the next line), then a previously successful authentication
            //  causes the next policy evaluation to succeed without testing biometry again.
            //  That's usually not what you want.
            state = .loggedout
            context = LAContext()
            context.localizedCancelTitle = "Cancel"
            
            // First check if we have the needed hardware support.
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                var reason = "Login to your account"
                if #available(iOS 11.0, *) {
                    if (context.biometryType != .faceID) {
                        reason = "Use Touch ID to login"
                    }
                }
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                    if success {
                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedin
                            completion!(true, nil, .loggedin)
                        }
                    } else {
                        let title = error?.localizedDescription ?? "Failed to authenticate"
                        
                        // If authentication failed then show a message to the console with a short description.
                        // In case that the error is a user fallback, then show the password alert view.
                        switch (error! as NSError).code {
                        case LAError.systemCancel.rawValue:
                            OperationQueue.main.addOperation({[unowned self] () -> Void in
                                let localError = self.createError(domain: NSOSStatusErrorDomain, code: 1000, text: "\(title): Authentication was cancelled by the system")
                                completion!(false, localError, self.state)
                            })
                        case LAError.userCancel.rawValue:
                            OperationQueue.main.addOperation({[unowned self] () -> Void in
                                let localError = self.createError(domain: NSOSStatusErrorDomain, code: 1001, text: "\(title): Authentication was cancelled by the user")
                                completion!(false, localError, self.state)
                            })
                        case LAError.userFallback.rawValue:
                            OperationQueue.main.addOperation({[unowned self] () -> Void in
                                let localError = self.createError(domain: NSOSStatusErrorDomain, code: 1002, text: "\(title): User selected to enter custom password")
                                completion!(false, localError, self.state)
                            })
                        default:
                            OperationQueue.main.addOperation({[unowned self] () -> Void in
                                let localError = self.createError(domain: NSOSStatusErrorDomain, code: 1003, text: title)
                                completion!(false, localError, self.state)
                            })
                        }
                    }
                }
            } else {
                var title: String?
                // Fall back to a asking for username and password.
                // ...
                // If the security policy cannot be evaluated then show a short message depending on the error.
                if #available(iOS 11.0, *) {
                    switch error!.code{
                    case LAError.biometryNotEnrolled.rawValue:
                        title = "TouchID is not enrolled"
                    case LAError.passcodeNotSet.rawValue:
                        title = "A passcode has not been set"
                    default:
                        // The LAError.TouchIDNotAvailable case.
                        title = "TouchID not available"
                    }
                } else {
                    // Fallback on earlier versions
                    title = error?.localizedDescription ?? "Can't evaluate policy"
                }
                
                // Optionally the error description can be displayed on the console.
                // Return the custom alert view to allow users to enter the password.
                let localError = self.createError(domain: NSOSStatusErrorDomain, code: 1003, text: title!)
                completion!(false, localError, self.state)
            }
        }
    }


    public func isLoggedIn() -> Bool {
        return state == .loggedin
    }
    public func isFaceId() -> Bool {
        return context.biometryType == .faceID
    }
    
    public func hello(text: String) -> String {
        return "Hello \(text) !"
    }

}

// MARK: - Utility methods

extension Validator {
    /*
     let localError: NSError = weakSelf!.createError(domain: NSOSStatusErrorDomain, code: -1001, text: "No values in the JSON returned") as NSError
     */
    #if os(iOS)
        public func createAlertController(error: Error?, title: String?) -> UIAlertController {
            var errorMessage = "Validation error encountered"
            if let validationError = error {
                errorMessage = validationError.localizedDescription
            }
            
            // alert user that our current record was deleted, and then we leave this view controller
            //
            let alert: UIAlertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
                // dissmissal of alert completed
            }
            alert.addAction(OKAction)
            return alert
        }
    #endif

    func createError(domain: String, code: Int, text: String) -> Error {
        let userInfo: [String : String] = [NSLocalizedDescriptionKey: text]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }

}
