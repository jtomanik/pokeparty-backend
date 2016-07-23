//
//  SlacketUserService.swift
//  Slacket
//
//  Created by Jakub Tomanik on 25/05/16.
//
//

import Foundation
import Promissum
import LoggerAPI
import PokePartyShared

typealias AuthId = String

protocol UserServiceProvider {

    static func auth(id: AuthId) -> Promise<User>
    static func update(user: User) -> Promise<User>
}

struct UserService: UserServiceProvider {

    static let errorDomain = "SignupService"

    static func auth(id: AuthId) -> Promise<User> {

        let source = PromiseSource<User>(dispatch: .Synchronous)
        let newUser = User(id: id)

        let existingUserPromise: Promise<User> = UserDataStore.sharedInstance.get(keyId: id)

        existingUserPromise
            .flatMapError(transform: { error throws -> Promise<User> in
                guard let userError =  error as? DataStoreError where userError == .notFound(key: id) else {
                    throw error
                }

                return UserDataStore.sharedInstance.set(data: newUser).flatMap(transform: { _ -> Promise<User> in
                    return UserDataStore.sharedInstance.get(keyId: newUser.keyId)
                })
            })
            .then(handler: { user in
                source.resolve(value: user)
            })
            .trap(handler: { error in
                source.reject(error: error)
            })

        return source.promise
    }

    static func update(user: User) -> Promise<User> {

        let source = PromiseSource<User>(dispatch: .Synchronous)

        let existingUserPromise: Promise<Bool> = UserDataStore.sharedInstance.set(data: user)

        existingUserPromise
            .flatMap(transform: { _ -> Promise<User> in
                return UserDataStore.sharedInstance.get(keyId: user.keyId)
            })
            .then(handler: { user in
                source.resolve(value: user)
            })
            .trap(handler: { error in
                source.reject(error: error)
            })
        
        return source.promise
    }
}