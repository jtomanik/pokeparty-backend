//
//  SlacketError.swift
//  Slacket
//
//  Created by Bartłomiej Nowak on 11/07/16.
//
//

import Foundation

enum PokePartyError: ErrorProtocol, Describable {

    case handlerActionCouldntInit
    case preconditionsNotMet
    case unknownError
    
    var description: String {
        switch self {
            case .handlerActionCouldntInit:
                return "HandlerAction init failed"
            case .preconditionsNotMet:
                return "Preconditions are not met"
            case .unknownError:
                return "Unknown error has occured"
        }
    }
}