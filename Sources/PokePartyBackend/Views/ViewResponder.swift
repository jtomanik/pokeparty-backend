//
//  ViewResponder.swift
//  PokePartyBackend
//
//  Created by Jakub Tomanik on 22/07/16.
//
//

import Foundation
import Kitura

protocol ViewResponder {

    var response: RouterResponse { get }

    init(response: RouterResponse)
}