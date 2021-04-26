//
//  ViewController+Ext.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 2/24/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

extension UIViewController
{
    var safeAreaLayoutFrame: CGRect {
      return view.safeAreaLayoutGuide.layoutFrame
    }
    
    func presentErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
