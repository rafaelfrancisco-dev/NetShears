//
//  RequestObservable.swift
//  
//
//  Created by Ali Moazenzadeh on 11/17/21.
//

import Foundation

protocol RequestObserverProtocol {
    func newRequestArrived(_ request: NetShearsRequestModel) async
}

final class RequestObserver: RequestObserverProtocol {
    let options: [RequestObserverProtocol]

    init(options: [RequestObserverProtocol]) {
        self.options = options
    }

    func newRequestArrived(_ request: NetShearsRequestModel) async {
        for option in options {
            await option.newRequestArrived(request)
        }
    }
}
