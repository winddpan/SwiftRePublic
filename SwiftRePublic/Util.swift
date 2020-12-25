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


extension ModifierDeclSyntaxProtocol {
    var isPublicModifier: Bool {
        let list: [TokenKind] = [.publicKeyword, .openKeyword]
        if let modifiers = modifiers, modifiers.contains(where: { m in list.contains(where: { $0 == m.name.tokenKind }) }) {
            return true
        }
        return false
    }

//    private var isPrivateModifier: Bool {
//        let list: [TokenKind] = [.privateKeyword, .fileprivateKeyword]
//        if let modifiers = modifiers, modifiers.contains(where: { m in list.contains(where: { $0 == m.name.tokenKind }) }) {
//            return true
//        }
//        return false
//    }
}
