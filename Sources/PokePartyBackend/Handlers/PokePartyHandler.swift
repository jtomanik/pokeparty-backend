//
//  SlackHandler.swift
//  Slacket
//
//  Created by Jakub Tomanik on 01/06/16.
//
//

import Foundation

import Kitura
import HeliumLogger
import LoggerAPI
import Promissum
import SwiftyJSON
import PokePartyShared

extension PokePartyAction: HandlerAction {

}

struct PokePartyHandler: RouterMiddleware, ErrorType {

    static let errorDomain = "PokePartyHandler"

    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        Log.debug("\(self.dynamicType.errorDomain) handler")

        guard let action = PokePartyAction(request: request) else {
                let error = PokePartyError.handlerActionCouldntInit
                Log.error(error)
                response.error = self.getError(message: error.description)
                next()
                return
        }

        switch action {
        case .signup:
            SignupHandler().handle(request: request, response: response, next: next)
        }
    }
}