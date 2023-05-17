//
//  UIAlertController + confirm.swift
//  HRTune
//
//  Created by kaoji on 5/15/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func presentAlert(on viewController: UIViewController,
                             title: String?,
                             message: String?,
                             confirmButtonTitle: String,
                             cancelButtonTitle: String?,
                             confirmHandler: (() -> Void)?,
                             cancelHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default) { (_) in
            confirmHandler?()
        }
        alertController.addAction(confirmAction)
        
        if let cancelButtonTitle = cancelButtonTitle {
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (_) in
                cancelHandler?()
            }
            alertController.addAction(cancelAction)
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
