//
//  UIViewController + Extension.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 8.02.2022.
//

import Foundation
import UIKit


extension UIViewController {
    
    func showAlert(message: String){
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
}
