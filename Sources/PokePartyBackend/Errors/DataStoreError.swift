//
//  DataStoreError.swift
//  Slacket
//
//  Created by Bartłomiej Nowak on 12/07/16.
//
//

import Foundation

public enum MethodType: String {
    case get
    case set
    case del
}

public enum DataStoreError: ErrorProtocol, Describable, Equatable {
    case missingRedisHostEnvVariable
    case notFound(key: String)
    case clientNotFound
    case failure(for: MethodType)
    case serializationFailure
    case deserializationFailure

    public var description: String {
        switch self {
        case .missingRedisHostEnvVariable:
            return "Cannot find REDIS_HOST environmental variable"
        case .notFound(let key):
            return "\(key) not found"
        case .clientNotFound:
            return "Client not found"
        case .failure(let methodType):
            return "\(methodType.rawValue) error"
        case .serializationFailure:
            return "Cannot serialize variable"
        case .deserializationFailure:
            return "Cannot deserialize variable"
        }
    }
}

public func ==(lhs: DataStoreError, rhs: DataStoreError) -> Bool {
    switch (lhs, rhs) {
    case(.missingRedisHostEnvVariable, .missingRedisHostEnvVariable):
        return true
    case (.notFound(let key1), .notFound(let key2)):
        return key1 == key2
    case(.clientNotFound, .clientNotFound):
        return true
    case (.failure(let m1), .failure(let m2)):
        return m1 == m2
    case(.serializationFailure, .serializationFailure):
        return true
    case(.deserializationFailure, .deserializationFailure):
        return true
    default:
        return false
    }
}