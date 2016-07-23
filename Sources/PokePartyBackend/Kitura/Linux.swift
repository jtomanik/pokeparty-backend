//
//  Linux.swift
//  Slacket
//
//  Created by Jakub Tomanik on 03/06/16.
//
//

import Foundation
import Socket

extension Sequence where Iterator.Element == String {

    func joinedBy(separator: String) -> String {
        return self.joined(separator: separator)
    }
}

extension NSData: SocketReader {
    public func readString() throws -> String? {
        return String(data: self, encoding: NSUTF8StringEncoding)
    }

    public func read(into data: NSMutableData) throws -> Int {
        return try self.read(into: data)
    }
}