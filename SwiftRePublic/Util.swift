//
//  Util.swift
//  SwiftRePublic
//
//  Created by PAN on 2020/12/25.
//

import Foundation
import SwiftSyntax

extension Array {
    subscript(safe index: Index) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set {
            if indices.contains(index), let value = newValue {
                self[index] = value
            }
        }
    }
}

extension Trivia {
    var spacing: Int {
        for piece in self {
            switch piece {
            case let .spaces(s):
                return s
            default:
                break
            }
        }
        return 0
    }
}
