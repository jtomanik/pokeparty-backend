//
//  SlacketUserDataStore.swift
//  Slacket
//
//  Created by Jakub Tomanik on 25/05/16.
//
//

import Foundation
import Redbird
import Kitura
import LoggerAPI
import Promissum
import PokePartyShared
import SwiftyJSON

extension Event: StorableType {

    var keyId: String {
        return "name:\(self.ownerId)"
    }
}

extension DetailedEvent: StorableType {

    var keyId: String {
        return "name:\(self.owner.id)"
    }
}

extension DetailedEvent: RedisStorableType {

    static func deserialize(redisObject: RespObject) -> DetailedEvent? {
        Log.debug("User deserialize")
        guard let serialized = try? redisObject.toString(),
            let data = serialized.data(using: NSUTF8StringEncoding) else {
                Log.debug(DataStoreError.deserializationFailure)
                return nil
        }
        let json = JSON(data: data)
        Log.debug("deserialize ok")
        return DetailedEventAdapter.parse(body: PayloadType.json(json)) as DetailedEvent?
    }

    func serialize() -> String? {
        Log.debug("SlacketUser serialize")
        guard let json = DetailedEventAdapter.encode(model: self) else {
            Log.debug(DataStoreError.serializationFailure)
            return nil
        }
        return json.description
    }
}

class EventDataStore: DataStoreProvider {

    typealias Storable = Event

    static let sharedInstance = EventDataStore()

    func get(keyId id: Storable.Identifier) -> Promise<Storable> {

        return DetailedEventDataStore.sharedInstance.get(keyId: id).map { $0.event }
    }

    func set(data: Storable) -> Promise<Bool> {

        let source = PromiseSource<Bool>(dispatch: .Synchronous)

        let members = whenAll(dispatch: .Synchronous, promises: data.memberIds.map { UserDataStore.sharedInstance.get(keyId: $0) })
        let operation = members
            .map(transform: { members throws -> DetailedEvent in
                let leaderId = data.ownerId
                guard let leader = members.filter({ $0.id == leaderId }).first else {
                    throw DataStoreError.notFound(key: leaderId)
                }
                return DetailedEvent(hash: data.hash, name: data.name, latitude: data.latitude, longitude: data.longitude, owner: leader, members: members)
            })
            .flatMap(transform: { detailed in
                return DetailedEventDataStore.sharedInstance.set(data: detailed)
            })
            .then(handler: { result in
                source.resolve(value: result)
            })
            .trap(handler: { error in
                source.reject(error: error)
            })

        return source.promise
    }

    func clear(keyId id: Storable.Identifier) -> Promise<Bool> {

        return DetailedEventDataStore.sharedInstance.clear(keyId: id)
    }
}

class DetailedEventDataStore: DataStoreProvider {

    typealias Storable = DetailedEvent

    static let sharedInstance = DetailedEventDataStore()

    func get(keyId id: Storable.Identifier) -> Promise<Storable> {
        if LaunchArgumentsProcessor.onLocalHost {
            return DetailedEventLocalDataStore.sharedInstance.get(keyId: id)
        } else {
            return DetailedEventRedisDataStore.sharedInstance.get(keyId: id)
        }
    }

    func set(data: Storable) -> Promise<Bool> {
        if LaunchArgumentsProcessor.onLocalHost {
            return DetailedEventLocalDataStore.sharedInstance.set(data: data)
        } else {
            return DetailedEventRedisDataStore.sharedInstance.set(data: data)
        }
    }

    func clear(keyId id: Storable.Identifier) -> Promise<Bool> {
        if LaunchArgumentsProcessor.onLocalHost {
            return DetailedEventLocalDataStore.sharedInstance.clear(keyId: id)
        } else {
            return DetailedEventRedisDataStore.sharedInstance.clear(keyId: id)
        }
    }
}

class DetailedEventRedisDataStore: RedisStoreProvider {

    typealias Storable = DetailedEvent

    static let sharedInstance = DetailedEventRedisDataStore()
}

class DetailedEventLocalDataStore: InMemoryStoreProvider {

    typealias Storable = DetailedEvent

    static let sharedInstance = DetailedEventLocalDataStore()
    
    var memoryStore: [Storable.Identifier: Storable] = [:]
}