//
//  ErrorView.swift
//  Slacket
//
//  Created by Jakub Tomanik on 23/06/16.
//
//

import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import SwiftyJSON
import PokePartyShared

enum ApiMessage {
    case user(User)
    case party(Party)
    case detailedParty(DetailedParty)
    case event(Event)
    case detailedEvent(DetailedEvent)


    var json: JSON? {
        switch self {
        case .user(let u):
            return UserAdapter.encode(model: u)
        case .party(let p):
            return PartyAdapter.encode(model: p)
        case .event(let e):
            return EventAdapter.encode(model: e)
        case .detailedParty(let p):
            return DetailedPartyAdapter.encode(model: p)
        case .detailedEvent(let e):
            return DetailedEventAdapter.encode(model: e)
        default:
            return nil
        }
    }
}

protocol ApiViewResponder: ParsedBodyResponder {

    func respond(message: ApiMessage)
}

struct ApiView: ApiViewResponder {

    let response: RouterResponse

    func respond(message: ApiMessage) {
        guard let json = message.json else {
            Log.debug("do proper error handling")
            return
        }
        let body = ParsedBody.json(json)
        self.show(body: body)
    }
}