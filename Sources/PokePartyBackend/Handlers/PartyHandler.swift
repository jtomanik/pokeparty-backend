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

extension PartyAction: HandlerAction {

    var requiredBodyType: ParsedBody? {
        switch self {
        case .update:
            return ParsedBody.json(JSON.null)
        default:
            return nil
        }
    }

    var requiredQueryParameters: [String]? {
        switch self {
        case .create:
            return ["name","owner"]
        case .join:
            return ["hash","user"]
        case .details:
            return ["id"]
        case .update:
            return ["id"]
        }
    }
}

struct PartyHandler: RouterMiddleware, ErrorType {

    static let errorDomain = "PartyHandler"

    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        Log.debug("\(self.dynamicType.errorDomain) handler")

        guard let action = PartyAction(request: request) else {
            let error = PokePartyError.handlerActionCouldntInit
            Log.error(error)
            response.error = self.getError(message: error.description)
            next()
            return
        }

        let errorView = ErrorView(response: response)
        let apiView = ApiView(response: response)

        switch action {
        case .create:
            if let name = request.queryParameters["name"],
                let owner = request.queryParameters["owner"] {
                PartyService.create(name: name, leaderId: owner)
                    .then(handler: { party in
                        apiView.respond(message: .party(party))
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
        case .join:
            if let hash = request.queryParameters["hash"],
                let user = request.queryParameters["user"] {
                PartyService.join(hash: hash, user: user)
                    .then(handler: { party in
                        apiView.respond(message: .party(party))
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

        case .details:
            if let id = request.queryParameters["id"] {
                PartyService.details(id: id)
                    .then(handler: { party in
                        apiView.respond(message: .detailedParty(party))
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

        case .update:
            if let id = request.queryParameters["id"],
                let body = request.body,
                let party = PartyAdapter.parse(body: body.payload) {
                PartyService.update(party: party)
                    .then(handler: { party in
                        apiView.respond(message: .party(party))
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