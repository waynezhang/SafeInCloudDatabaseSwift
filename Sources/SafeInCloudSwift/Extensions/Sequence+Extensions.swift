//
//  Sequence+Extensions.swift
//  Sequence+Extensions
//
//  Created by waynezhang on 2021/08/24.
//

import Foundation

#if DEBUG
extension Sequence where Element == UInt8 {
    func toHexString() -> String {
        map { String(format: "%02X", $0) }.joined()
    }
}
#endif
