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

extension User: StorableType {

    var keyId: String {
        return self.id
    }
}

extension User: RedisStorableType {

    static func deserialize(redisObject: RespObject) -> User? {
        Log.debug("User deserialize")
        guard let serialized = try? redisObject.toString(),
            let data = serialized.data(using: NSUTF8StringEncoding) else {
                Log.debug(DataStoreError.deserializationFailure)
                return nil
        }
        let json = JSON(data: data)
        Log.debug("deserialize ok")
        return UserAdapter.parse(body: PayloadType.json(json)) as User?
    }

    func serialize() -> String? {
        Log.debug("SlacketUser serialize")
        guard let json = UserAdapter.encode(model: self) else {
            Log.debug(DataStoreError.serializationFailure)
            return nil
        }
        return json.description
    }
}

class UserDataStore: DataStoreProvider {

    typealias Storable = User

    static let sharedInstance = UserDataStore()

    func get(keyId id: Storable.Identifier) -> Promise<Storable> {
        if LaunchArgumentsProcessor.onLocalHost {
            return UserLocalDataStore.sharedInstance.get(keyId: id)
        } else {
            return UserRedisDataStore.sharedInstance.get(keyId: id)
        }
    }

    func set(data: Storable) -> Promise<Bool> {
        if LaunchArgumentsProcessor.onLocalHost {
            return UserLocalDataStore.sharedInstance.set(data: data)
        } else {
            return UserRedisDataStore.sharedInstance.set(data: data)
        }
    }

    func clear(keyId id: Storable.Identifier) -> Promise<Bool> {
        if LaunchArgumentsProcessor.onLocalHost {
            return UserLocalDataStore.sharedInstance.clear(keyId: id)
        } else {
            return UserRedisDataStore.sharedInstance.clear(keyId: id)
        }
    }
}

class UserRedisDataStore: RedisStoreProvider {

    typealias Storable = User

    static let sharedInstance = UserRedisDataStore()
}

class UserLocalDataStore: InMemoryStoreProvider {

    typealias Storable = User

    static let sharedInstance = UserLocalDataStore()

    var memoryStore: [Storable.Identifier: Storable] = [:]
}