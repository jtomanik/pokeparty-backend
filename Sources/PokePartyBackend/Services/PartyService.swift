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

protocol PartyServiceProvider {

    static func create(name: String, leaderId: String) -> Promise<Party>
    static func join(hash: String, user: String) -> Promise<Party>
    static func details(id: String) -> Promise<DetailedParty>
    static func update(party: Party) -> Promise<Party>
}

struct PartyService: PartyServiceProvider {

    typealias Store = PartyDataStore
    typealias DetailStore = DetailedPartyDataStore

    static let errorDomain = "PartyService"

    static func create(name: String, leaderId: String) -> Promise<Store.Storable> {

        let source = PromiseSource<Store.Storable>(dispatch: .Synchronous)
        var newElement = Store.Storable(name: name, leaderId: leaderId)

        let existingPromise: Promise<Party> = Store.sharedInstance.get(keyId: newElement.keyId)

        existingPromise
            .flatMapError(transform: { error throws -> Promise<Store.Storable> in
                guard let userError =  error as? DataStoreError where userError == .notFound(key: newElement.keyId) else {
                    throw error
                }

                newElement.id = newElement.keyId
                newElement.hash = newElement.id
                newElement.memberIds = [leaderId]

                return Store.sharedInstance.set(data: newElement).flatMap(transform: { _ -> Promise<Store.Storable> in
                    return Store.sharedInstance.get(keyId: newElement.keyId)
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

    static func join(hash: String, user: String) -> Promise<Store.Storable> {

        let source = PromiseSource<Store.Storable>(dispatch: .Synchronous)

        let user: Promise<User> = UserDataStore.sharedInstance.get(keyId: user)

        let party: Promise<DetailedParty> = DetailedPartyDataStore.sharedInstance.get(keyId: hash)
        let leader = party.map(transform: { $0.leader })

        let users = whenAll(promises: [user,leader])
        let validate = users.map(transform: { array throws -> User in
            guard let user = array.first where array.count == 2,
                let owner = array.last where user.team == owner.team else {
                    throw DataStoreError.notFound(key: "")
            }
            return user
        })

        let process = whenBoth(promiseA: party, validate)
            .flatMap(transform: { (party, user) -> Promise<Bool> in
                var party = party
                party.members.append(user)

                return DetailedPartyDataStore.sharedInstance.set(data: party)
            })
            .flatMap(transform: { _ -> Promise<Party> in
                return PartyDataStore.sharedInstance.get(keyId: hash)
            })
            .then(handler: { party in
                source.resolve(value: party)
            })
            .trap( handler: { error in
                source.reject(error: error)
            })


        return source.promise
    }

    static func details(id: String) -> Promise<DetailStore.Storable> {

        return DetailStore.sharedInstance.get(keyId: id)
    }

    static func update(party: Store.Storable) -> Promise<Store.Storable> {

        let element = party
        let source = PromiseSource<Store.Storable>(dispatch: .Synchronous)

        let existingPromise: Promise<Bool> = Store.sharedInstance.set(data: element)

        existingPromise
            .flatMap(transform: { _ -> Promise<Store.Storable> in
                return Store.sharedInstance.get(keyId: element.keyId)
            })
            .then(handler: { element in
                source.resolve(value: element)
            })
            .trap(handler: { error in
                source.reject(error: error)
            })
        
        return source.promise
    }
}