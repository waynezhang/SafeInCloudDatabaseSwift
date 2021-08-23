//
//  SafeInCloudDatabase.swift
//  SafeInCloudDatabase
//
//  Created by waynezhang on 2021/08/23.
//

import Foundation
import CommonCrypto
import Compression

// MARK: - SafeInCloudDatabaseError

public enum SafeInCloudDatabaseError: Error {
    case FileNotFound
    case FileAccessError
    case FormatError
}

// MARK: - Card

public struct Card {
    
    public struct Field {
        public enum FieldType: String {
            case login
            case password
            case website
            case oneTimePassword = "one_time_password"
            case number
            case text
            case pin
            case expiry
            case phone
            case date
            case secret
        }

        public let name: String
        public let value: String
        public let type: FieldType
    }

    public let title: String
    public let id: String
    public let fields: [Field]
}

// MARK: - SafeInCloudDatabase

public struct SafeInCloudDatabase {

    public private(set) var allCards: [Card] = []

    public init(filePath: String, password: String) throws {
        let data = try decrypt(filePath: filePath, password: password)
        let document = try XMLDocument(data: data, options: [])
        guard let rootNode = document.children?.first else {
            throw SafeInCloudDatabaseError.FormatError
        }

        allCards = parseCards(rootNode)
    }
}

// MARK: - Decryption

extension SafeInCloudDatabase {

    private func decrypt(filePath: String, password: String) throws -> Data {
        guard FileManager.default.fileExists(atPath: filePath) else {
            throw SafeInCloudDatabaseError.FileNotFound
        }
        guard let stream = InputStream(fileAtPath: filePath) else {
            throw SafeInCloudDatabaseError.FileAccessError
        }

        stream.open()
        defer { stream.close() }

        // magic
        try stream.readShort()
        // sver
        try stream.readByte()

        let salt = try stream.readArray()
        let key = try CryptoUtils.pbkdf2(password: password, salt: salt, iterations: 10000, keyLength: 32)
        let iv = try stream.readArray()

        #if DEBUG
        print("salt: \(salt.toHexString())")
        print("key: \(key.toHexString())")
        print("iv: \(iv.toHexString())")
        #endif

        let salt2 = try stream.readArray()
        let secondCredentials = try stream.readArray()
        let decryptedSecondCredentials = try CryptoUtils.AESDecrypt(Data(secondCredentials), key:key, iv: iv)

        let (iv2, password2) = try decryptSecondCredentials(decryptedSecondCredentials)

        #if DEBUG
        print("salt2: \(salt2.toHexString())")
        print("iv2: \(iv2.toHexString())")
        print("password2: \(password2.toHexString())")
        #endif

        let body = try Data(stream: stream)
        let bodyData = try CryptoUtils.AESDecrypt(body, key: password2, iv: iv2)

        #if DEBUG
        print("data: \([UInt8](bodyData[0..<16]).toHexString())")
        #endif

        // drop head bytes
        return (try (bodyData.dropFirst(2) as NSData).decompressed(using: .zlib)) as Data
    }

    private func decryptSecondCredentials(_ data: Data) throws -> (iv: [UInt8], password: [UInt8]) {
        let stream = InputStream(data: data)
        stream.open()
        defer { stream.close() }

        let iv = try stream.readArray()
        let password = try stream.readArray()

        return (iv: iv, password: password)
    }
}

// MARK: - Parse

extension SafeInCloudDatabase {

    private func parseCards(_ node: XMLNode) -> [Card] {
        node.children?.compactMap { ele -> Card? in
            guard
                let ele = ele as? XMLElement, ele.name == "card",
                ele.attribute(forName: "autofill")?.stringValue == "on"
            else { return nil }

            let title = ele.attribute(forName: "title")?.stringValue ?? ""
            let id = ele.attribute(forName: "id")?.stringValue ?? ""
            let fields = ele.children?.compactMap(parseField) ?? []
            return Card(title: title, id: id, fields: fields)
        } ?? []
    }

    private func parseField(_ node: XMLNode) -> Card.Field? {
        guard
            let ele = node as? XMLElement,
            ele.name == "field",
            let rawType = ele.attribute(forName: "type")?.stringValue,
            let type = Card.Field.FieldType(rawValue: rawType)
        else { return nil }

        return Card.Field(
            name: ele.attribute(forName: "name")?.stringValue ?? "",
            value: ele.stringValue ?? "",
            type: type
        )
    }
}
