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

extension SignupAction: HandlerAction {

    var requiredBodyType: ParsedBody? {
        switch self {
        case .googleAuth:
            return nil
        case .userSetup:
            return ParsedBody.json(JSON.null)
        }
    }

    var requiredQueryParameters: [String]? {
        switch self {
        case .googleAuth:
            return ["id"]
        case .userSetup:
            return nil
        }
    }
}

struct SignupHandler: RouterMiddleware, ErrorType {

    static let errorDomain = "PokePartyHandler"

    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        Log.debug("\(self.dynamicType.errorDomain) handler")

        guard let action = SignupAction(request: request) else {
                let error = PokePartyError.handlerActionCouldntInit
                Log.error(error)
                response.error = self.getError(message: error.description)
                next()
                return
        }

        let errorView = ErrorView(response: response)
        let apiView = ApiView(response: response)

        switch action {
        case .googleAuth:
            if let authId = request.queryParameters["id"] {
                UserService.auth(id: authId)
                    .then(handler: { user in
                        apiView.respond(message: .user(user))
                    }).trap(handler: { error in
                        let error = error as! Describable
                        Log.error(error)
                        errorView.error(message: error.description)
                    })
            } else {
                let error = PokePartyError.preconditionsNotMet
                Log.error(error)
                errorView.error(message: error.description)
                return
            }
        case .userSetup:
            if let body = request.body,
                let user = UserAdapter.parse(body: body.payload) {
                UserService.update(user: user)
                    .then(handler: { user in
                        apiView.respond(message: .user(user))
                    }).trap(handler: { error in
                        let error = error as! Describable
                        Log.error(error)
                        errorView.error(message: error.description)
                    })
            } else {
                let error = PokePartyError.preconditionsNotMet
                Log.error(error)
                errorView.error(message: error.description)
                return
            }
        }
    }
}