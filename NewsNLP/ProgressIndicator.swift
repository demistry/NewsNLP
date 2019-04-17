//
//  ProgressIndicator.swift
//  NewsNLP
//
//  Created by David Ilenwabor on 17/04/2019.
//  Copyright © 2019 Demistry. All rights reserved.
//

import Foundation
import JGProgressHUD

class ProgressIndicator{
    class func showProgress(on view : UIView,with message : String)->JGProgressHUD{
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = message
        hud.show(in: view)
        return hud
    }
}
