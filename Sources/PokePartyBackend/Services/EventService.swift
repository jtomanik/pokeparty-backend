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

protocol EventServiceProvider {

    static func create(name: String, ownerId: String, latitude: Double, longitude: Double, description: String) -> Promise<Event>
    static func join(hash: String, user: String) -> Promise<Event>
    static func details(id: String) -> Promise<DetailedEvent>
    static func update(event: Event) -> Promise<Event>
}

struct EventService: EventServiceProvider {

    typealias Store = EventDataStore
    typealias DetailStore = DetailedEventDataStore

    static let errorDomain = "EventService"

    static func create(name: String, ownerId: String, latitude: Double, longitude: Double, description: String) -> Promise<Store.Storable> {

        let source = PromiseSource<Store.Storable>(dispatch: .Synchronous)
        var newElement = Store.Storable(name: name, latitude: latitude, longitude: longitude, ownerId: ownerId)
        newElement.description = description

        let existingPromise: Promise<Event> = Store.sharedInstance.get(keyId: newElement.keyId)
        existingPromise
            .then(handler: { event in
                source.resolve(value: event)
            })

        let newPromise = existingPromise.mapVoid()
            .map(transform: { _ -> Bool in
                return true
            })
            .flatMapError(transform: { error throws -> Promise<Bool> in
                guard let userError =  error as? DataStoreError where userError == .notFound(key: newElement.keyId) else {
                    throw error
                }

                newElement.id = newElement.keyId
                newElement.hash = newElement.id
                newElement.memberIds = [ownerId]

                return Store.sharedInstance.set(data: newElement)
            })
            .flatMap(transform: { _ -> Promise<Store.Storable> in
                return Store.sharedInstance.get(keyId: newElement.keyId)
            })
            .then(handler: { event in
                source.resolve(value: event)
            })
            .trap(handler: { error in
                source.reject(error: error)
            })

        return source.promise
    }

    static func join(hash: String, user: String) -> Promise<Store.Storable> {

        let source = PromiseSource<Store.Storable>(dispatch: .Synchronous)

        let user: Promise<User> = UserDataStore.sharedInstance.get(keyId: user)

        let event: Promise<DetailedEvent> = DetailedEventDataStore.sharedInstance.get(keyId: hash)
        let owner = event.map(transform: { $0.owner })

        let users = whenAll(dispatch: .Synchronous, promises: [user,owner])
        let validate = users.map(transform: { array throws -> User in
            guard let user = array.first where array.count == 2,
                let owner = array.last where user.team == owner.team else {
                    throw DataStoreError.notFound(key: "")
            }
            return user
        })

        let process = whenBoth(promiseA: event, validate)
            .flatMap(transform: { (event, user) -> Promise<Bool> in
                var event = event
                event.members.append(user)

                return DetailedEventDataStore.sharedInstance.set(data: event)
            })
            .flatMap(transform: { _ -> Promise<Event> in
                return EventDataStore.sharedInstance.get(keyId: hash)
            })
            .then(handler: { event in
                source.resolve(value: event)
            })
            .trap( handler: { error in
                source.reject(error: error)
            })


        return source.promise
    }

    static func details(id: String) -> Promise<DetailStore.Storable> {

        return DetailStore.sharedInstance.get(keyId: id)
    }

    static func update(event: Store.Storable) -> Promise<Store.Storable> {

        let element = event
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