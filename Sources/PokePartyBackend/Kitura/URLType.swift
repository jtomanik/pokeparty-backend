//
//  URLType.swift
//  Slacket
//
//  Created by Jakub Tomanik on 20/05/16.
//
//

import Foundation

protocol ErrorType {
    
    static var errorDomain: String { get }
}

extension ErrorType {
    
    func getError(message: String) -> NSError {
        return NSError(domain: Self.errorDomain,
                                 code: 1,
                                 userInfo: nil)
    }
}