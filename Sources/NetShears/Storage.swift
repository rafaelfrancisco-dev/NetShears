//
//  Storage.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/9/21.
//
//

import Foundation

final actor Storage: NSObject {
    static let shared: Storage = Storage()

    private(set) var requests: [NetShearsRequestModel] = []
    
    func filteredRequests() async -> [NetShearsRequestModel] {
        return await getFilteredRequests()
    }

    func saveRequest(request: NetShearsRequestModel) {
        if let index = self.requests.firstIndex(where: { (req) -> Bool in
            return request.id == req.id ? true : false
        }) {
            self.requests[index] = request
        } else {
            self.requests.insert(request, at: 0)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.NewRequestNotification, object: nil)
    }

    func clearRequests() {
        self.requests.removeAll()
    }

    private func getFilteredRequests() async -> [NetShearsRequestModel] {
        var localRequests = [NetShearsRequestModel]()
        localRequests = requests
        return await Self.filterRequestsIfNeeded(localRequests)
    }

    private static func filterRequestsIfNeeded(_ requests: [NetShearsRequestModel]) async -> [NetShearsRequestModel] {
        guard case Ignore.enabled(let ignoreHandler) = await NetShears.shared.ignore else {
            return requests
        }
        
        return  requests.filter { ignoreHandler($0) == false }
    }

}
