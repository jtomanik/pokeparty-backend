//
//  Slacket.swift
//  Slacket
//
//  Created by Jakub Tomanik on 30/05/16.
//
//

import Foundation
import Kitura
import LoggerAPI
import PokePartyShared

import libc

struct ServerConfig: URLType {
    
    let host: String
    let port: Int?
    
    init() {
        if LaunchArgumentsProcessor.onLocalHost {
            self.host = "localhost"
            self.port = 8090
        } else {
            self.host = "pokeparty.rocks"
            self.port = nil
        }
    }
}

struct PokeParty: ServerModuleType {

    private let router: Router

    init(using router: Router) {
        if LaunchArgumentsProcessor.onLocalHost {
            Log.debug("running locally")
        }
        self.router = router
        self.setupRoutes()
    }

    mutating func setupRoutes() {
        let _ = router.get("/", middleware: StaticFileServer(path: repoDirectory+"public/"))
        router.all("api/*", middleware: BodyParser())
        router.all("api/*", middleware: PokePartyHandler())
    }
}