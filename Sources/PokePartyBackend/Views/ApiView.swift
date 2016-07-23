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

    var json: JSON? {
        switch self {
        case .user(let u):
            return UserAdapter.encode(model: u)
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