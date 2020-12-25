//
//  Protocol.swift
//  SwiftRePublic
//
//  Created by PAN on 2020/12/24.
//

import Foundation
import SwiftSyntax

protocol ModifierDeclSyntaxProtocol: DeclSyntaxProtocol {
    var modifiers: ModifierListSyntax? { get }

    /// Adds the provided `Modifier` to the node's `modifiers`
    /// collection.
    /// - param element: The new `Modifier` to add to the node's
    ///                  `modifiers` collection.
    /// - returns: A copy of the receiver with the provided `Modifier`
    ///            appended to its `modifiers` collection.
    func addModifier(_ element: DeclModifierSyntax) -> Self

    /// Returns a copy of the receiver with its `modifiers` replaced.
    /// - param newChild: The new `modifiers` to replace the node's
    ///                   current `modifiers`, if present.
    func withModifiers(_ newChild: ModifierListSyntax?) -> Self

    static var openAvaiable: Bool { get }
}

extension VariableDeclSyntax: ModifierDeclSyntaxProtocol {
    static var openAvaiable: Bool {
        return true
    }
}

extension FunctionDeclSyntax: ModifierDeclSyntaxProtocol {
    static var openAvaiable: Bool {
        return true
    }
}

extension InitializerDeclSyntax: ModifierDeclSyntaxProtocol {
    static var openAvaiable: Bool {
        return false
    }
}

extension EnumDeclSyntax: ModifierDeclSyntaxProtocol {
    static var openAvaiable: Bool {
        return false
    }
}

extension StructDeclSyntax: ModifierDeclSyntaxProtocol {
    static var openAvaiable: Bool {
        return false
    }
}

extension ClassDeclSyntax: ModifierDeclSyntaxProtocol {
    static var openAvaiable: Bool {
        return true
    }
}

extension ProtocolDeclSyntax: ModifierDeclSyntaxProtocol {
    static var openAvaiable: Bool {
        return false
    }
}
