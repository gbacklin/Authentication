//
//  SuccessViewController.swift
//  TerstMyFramework
//
//  Created by Gene Backlin on 7/27/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    var isLoggedIn = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Success: \(isLoggedIn)"
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
