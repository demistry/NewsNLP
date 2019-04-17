//
//  AlertDisplay.swift
//  NewsNLP
//
//  Created by David Ilenwabor on 17/04/2019.
//  Copyright © 2019 Demistry. All rights reserved.
//

import Foundation
import UIKit

class AlertDisplay{
    
    static func showAlert(withTitle title : String,forMessage message : String, onViewController viewController : UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
