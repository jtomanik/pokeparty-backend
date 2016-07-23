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

    private struct SharedConfig: BackendConfig {}
    private let sharedConfig = SharedConfig()

    let host: String
    let port: Int?
    
    init() {
        if LaunchArgumentsProcessor.onLocalHost {
            self.host = "localhost"
            self.port = 8090
        } else {
            self.host = sharedConfig.host
            self.port = sharedConfig.port
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