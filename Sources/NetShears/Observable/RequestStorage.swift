//
//  RequestStorage.swift
//  
//
//  Created by Ali Moazenzadeh on 11/17/21.
//

import Foundation

final actor RequestStorage: RequestObserverProtocol {
    static let shared = RequestStorage()

    private init() {}
    
    func newRequestArrived(_ request: NetShearsRequestModel) async {
        await Storage.shared.saveRequest(request: request)
    }
}
