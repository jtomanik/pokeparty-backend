//
//  AdapterError.swift
//  Slacket
//
//  Created by Bartłomiej Nowak on 11/07/16.
//
//

import Foundation

enum AdapterError: ErrorProtocol, Describable {
    case parserFailedDecoding
    
    var description: String {
        switch self {
            case .parserFailedDecoding:
                return "Parser failed decoding SlacketUser"
        }
    }
}