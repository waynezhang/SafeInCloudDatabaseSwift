//
//  InputStream+Extensions.swift
//  InputStream+Extensions
//
//  Created by waynezhang on 2021/08/20.
//

import Foundation
import OSLog

extension InputStream {

    @discardableResult
    func readByte() throws -> UInt8 {
        try readBytes(bytes: 1)[0]
    }

    @discardableResult
    func readShort() throws -> UInt16 {
        let buffer = try readBytes(bytes: 2)
        let bigEndianValue = buffer.withUnsafeBufferPointer { pointer in
            pointer.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1, { $0 })
        }.pointee

        return UInt16(bigEndian: bigEndianValue)
    }

    @discardableResult
    func readArray() throws -> [UInt8] {
        let count = try readByte()
        return try readBytes(bytes: Int(count))
    }

    @discardableResult
    private func readBytes(bytes: Int) throws -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: bytes)
        let read = read(&buffer, maxLength: bytes)
        guard read == bytes else {
            throw SafeInCloudDatabaseError.FormatError
        }

        return buffer
    }
}
