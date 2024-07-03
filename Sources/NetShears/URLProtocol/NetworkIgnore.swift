//
//  NetworkIgnore.swift
//  
//
//  Created by Mehrdad Goodarzi(Arash) on 6/24/22.
//

import Foundation

public enum Ignore: Sendable {
    case disbaled
    case enabled(ignoreHandler: @Sendable (NetShearsRequestModel) -> Bool)
}
