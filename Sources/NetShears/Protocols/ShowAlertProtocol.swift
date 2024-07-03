//
//  ShowAlertProtocol.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 7/7/21.
//

import UIKit

protocol ShowAlertProtocol {
    func showAlert(alertMessage : String)
}

extension ShowLoaderProtocol where Self: UIViewController {
    func showAlert(alertMessage : String) async {
        let alert = await UIAlertController(title: nil, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        await alert.addAction(UIAlertAction(title: "Got it", style: UIAlertAction.Style.default, handler: nil))
        
        await self.present(alert, animated: true, completion: nil)
    }
}
