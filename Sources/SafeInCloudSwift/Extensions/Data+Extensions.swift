//
//  Data+Extensions.swift
//  Data+Extensions
//
//  Created by waynezhang on 2021/08/20.
//

import Foundation
import CommonCrypto

extension Data {

    init(stream: InputStream) throws {
        self.init()

        let bufferSize = 1024 * 10
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            guard read >= 0 else { throw stream.streamError! }
            if read == 0 {
                break
            }
            append(buffer, count: read)
        }
    }
}
