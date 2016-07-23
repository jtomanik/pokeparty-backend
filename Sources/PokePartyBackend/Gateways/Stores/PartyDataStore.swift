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

extension Party: StorableType {

    var keyId: String {
        return "name:\(self.leaderId)"
    }
}

extension DetailedParty: StorableType {

    var keyId: String {
        return "name:\(self.leader.id)"
    }
}

extension DetailedParty: RedisStorableType {

    static func deserialize(redisObject: RespObject) -> DetailedParty? {
        Log.debug("User deserialize")
        guard let serialized = try? redisObject.toString(),
            let data = serialized.data(using: NSUTF8StringEncoding) else {
                Log.debug(DataStoreError.deserializationFailure)
                return nil
        }
        let json = JSON(data: data)
        Log.debug("deserialize ok")
        return DetailedPartyAdapter.parse(body: PayloadType.json(json)) as DetailedParty?
    }

    func serialize() -> String? {
        Log.debug("SlacketUser serialize")
        guard let json = DetailedPartyAdapter.encode(model: self) else {
            Log.debug(DataStoreError.serializationFailure)
            return nil
        }
        return json.description
    }
}

class PartyDataStore: DataStoreProvider {

    typealias Storable = Party

    static let sharedInstance = PartyDataStore()

    func get(keyId id: Storable.Identifier) -> Promise<Storable> {

        return DetailedPartyDataStore.sharedInstance.get(keyId: id).map { $0.party }
    }

    func set(data: Storable) -> Promise<Bool> {

        let source = PromiseSource<Bool>()

        let members = whenAll(promises: data.memberIds.map { UserDataStore.sharedInstance.get(keyId: $0) })
        let operation = members
            .map(transform: { members throws -> DetailedParty in
                let leaderId = data.leaderId
                guard let leader = members.filter({ $0.id == leaderId }).first else {
                    throw DataStoreError.notFound(key: leaderId)
                }
                return DetailedParty(id: data.id, hash: data.hash, name: data.name, leader: leader, members: members)
            })
            .flatMap(transform: { detailed in
                return DetailedPartyDataStore.sharedInstance.set(data: detailed)
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

        return DetailedPartyDataStore.sharedInstance.clear(keyId: id)
    }
}

class DetailedPartyDataStore: DataStoreProvider {

    typealias Storable = DetailedParty

    static let sharedInstance = DetailedPartyDataStore()

    func get(keyId id: Storable.Identifier) -> Promise<Storable> {
        if LaunchArgumentsProcessor.onLocalHost {
            return DetailedPartyLocalDataStore.sharedInstance.get(keyId: id)
        } else {
            return DetailedPartyRedisDataStore.sharedInstance.get(keyId: id)
        }
    }

    func set(data: Storable) -> Promise<Bool> {
        if LaunchArgumentsProcessor.onLocalHost {
            return DetailedPartyLocalDataStore.sharedInstance.set(data: data)
        } else {
            return DetailedPartyRedisDataStore.sharedInstance.set(data: data)
        }
    }

    func clear(keyId id: Storable.Identifier) -> Promise<Bool> {
        if LaunchArgumentsProcessor.onLocalHost {
            return DetailedPartyLocalDataStore.sharedInstance.clear(keyId: id)
        } else {
            return DetailedPartyRedisDataStore.sharedInstance.clear(keyId: id)
        }
    }
}

class DetailedPartyRedisDataStore: RedisStoreProvider {

    typealias Storable = DetailedParty

    static let sharedInstance = DetailedPartyRedisDataStore()
}

class DetailedPartyLocalDataStore: InMemoryStoreProvider {

    typealias Storable = DetailedParty

    static let sharedInstance = DetailedPartyLocalDataStore()
    
    var memoryStore: [Storable.Identifier: Storable] = [:]
}