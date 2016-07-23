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

extension EventAction: HandlerAction {

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
            return ["name","owner", "latitude", "longitude", "description"]
        case .join:
            return ["hash","user"]
        case .details:
            return ["id"]
        case .update:
            return ["id"]
        }
    }
}

struct EventHandler: RouterMiddleware, ErrorType {

    static let errorDomain = "EventHandler"

    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        Log.debug("\(self.dynamicType.errorDomain) handler")

        guard let action = EventAction(request: request) else {
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
                let owner = request.queryParameters["owner"],
                let lat = request.queryParameters["latitude"],
                let lon = request.queryParameters["longitude"],
                let latitude = Double(lat),
                let longitude = Double(lon),
                let description = request.queryParameters["description"] {
                EventService.create(name: name, ownerId: owner, latitude: latitude, longitude: longitude, description: description)
                    .then(handler: { event in
                        apiView.respond(message: .event(event))
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
                EventService.join(hash: hash, user: user)
                    .then(handler: { event in
                        apiView.respond(message: .event(event))
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
                EventService.details(id: id)
                    .then(handler: { event in
                        apiView.respond(message: .detailedEvent(event))
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
                let event = EventAdapter.parse(body: body.payload) {
                EventService.update(event: event)
                    .then(handler: { event in
                        apiView.respond(message: .event(event))
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