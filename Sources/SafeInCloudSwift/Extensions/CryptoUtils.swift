//
//  CryptoUtils.swift
//  CryptoUtils
//
//  Created by waynezhang on 2021/08/20.
//

import Foundation
import CommonCrypto
import CoreVideo

enum CryptoUtils {

    enum Error: Swift.Error {
        case CryptoError(code: Int32)
    }

    static func pbkdf2(password: String, salt: [UInt8], iterations: UInt32, keyLength: Int) throws -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: keyLength)
        let result = CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            password,
            password.count,
            salt,
            salt.count,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
            iterations,
            &hash,
            keyLength
        )
        guard result == kCCSuccess else {
            throw Error.CryptoError(code: result)
        }
        return hash
    }

    static func AESDecrypt(_ data: Data, key: [UInt8], iv: [UInt8]) throws -> Data {
        var buffer = [UInt8](repeating: 0, count: data.count)
        var decryptedCount = 0

        try data.withUnsafeBytes { pointer in
            let result = CCCrypt(
                CCOperation(kCCDecrypt),
                CCAlgorithm(kCCAlgorithmAES),
                CCOptions(kCCOptionPKCS7Padding),
                key,
                key.count,
                iv,
                pointer.baseAddress,
                data.count,
                &buffer,
                buffer.count,
                &decryptedCount
            )
            guard result == kCCSuccess else {
                throw Error.CryptoError(code: result)
            }
        }

        return Data(buffer)
    }
}

