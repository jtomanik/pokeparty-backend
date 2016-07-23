//
//  ParsedBody+Extensions.swift
//  PokePartyBackend
//
//  Created by Jakub Tomanik on 22/07/16.
//
//

import Foundation
import Kitura
import SwiftyJSON
import LoggerAPI
import PokePartyShared

enum ContentType {
    case text
    case formUrlEncoded
    case json
    case multipart
    case binary

    var value: String {
        switch self {
        case .text:
            return "text/plain"
        case .formUrlEncoded:
            return "application/x-www-form-urlencoded"
        case .json:
            return "application/json"
        case .multipart:
            return "multipart/mixed"
        case .binary:
            return "application/binary"
        }
    }
}

extension ParsedBody {

    var isUTF8: Bool {
        return true
    }

    var contentType: String {
        switch self {
        case .text:
            return "text/plain"
        case .urlEncoded:
            return "application/x-www-form-urlencoded"
        case .json:
            return "application/json"
        case .multipart:
            return "multipart/mixed"
        case raw:
            return "application/binary"
        }
    }

    var contentTypeHeaderKey: String {
        return "Content-Type"
    }

    var contentTypeHeaderValue: String {
        var contentType = self.contentType
        contentType += isUTF8 ? "; charset=utf-8" : ""
        return contentType
    }

    var header: [String: String] {
        return [contentTypeHeaderKey: contentTypeHeaderValue]

    }

    func isSameTypeAs(other: ParsedBody) -> Bool {
        switch (self, other) {
        case (.json, .json):
            return true
        case (.text, .text):
            return true
        case (.urlEncoded, .urlEncoded):
            return true
        default:
            return false
        }
    }

    var payload: PayloadType? {
        switch self {
        case .text(let t):
            return PayloadType.text(t)
        case .urlEncoded(let u):
            return PayloadType.urlEncoded(u)
        case .json(let j):
            return PayloadType.json(j)
        case raw(let b):
            return PayloadType.raw(b)
        default:
            return nil
        }
    }
}

extension PayloadType {

    func isSameTypeAs(other: PayloadType) -> Bool {
        switch (self, other) {
        case (.json, .json):
            return true
        case (.text, .text):
            return true
        case (.urlEncoded, .urlEncoded):
            return true
        default:
            return false
        }
    }

    var parsedBody: ParsedBody? {
        switch self {
        case .text(let t):
            return ParsedBody.text(t)
        case .urlEncoded(let u):
            return ParsedBody.urlEncoded(u)
        case .json(let j):
            return ParsedBody.json(j)
        case raw(let b):
            return ParsedBody.raw(b)
        default:
            return nil
        }
    }
}

extension RouterMethod {

    func toMethod() -> PokePartyShared.Method {
        let string = self.rawValue
        let method = PokePartyShared.Method(string: string)
        return method ?? PokePartyShared.Method.error
    }
}