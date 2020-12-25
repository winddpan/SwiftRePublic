//
//  RePublicRewriter.swift
//  SwiftRePublic
//
//  Created by PAN on 2020/12/24.
//

import Foundation
import SwiftSyntax

extension TokenKind {
    static var openKeyword: TokenKind {
        return TokenKind.identifier("open")
    }
}

class RePublicRewriter: SyntaxRewriter {
    enum Mode {
        case `public`
        case open
    }

    let mode: Mode

    required init(mode: Mode) {
        self.mode = mode
    }

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        if node.shouldPublic {
            return super.visit(publicDeclNode(node))
        } else {
            return super.visit(unPublicDeclNode(node))
        }
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        if node.shouldPublic {
            return super.visit(publicDeclNode(node))
        } else {
            return super.visit(unPublicDeclNode(node))
        }
    }

    override func visit(_ node: ProtocolDeclSyntax) -> DeclSyntax {
        return super.visit(publicDeclNode(node))
    }

    override func visit(_ node: InitializerDeclSyntax) -> DeclSyntax {
        if node.shouldPublic {
            return super.visit(publicDeclNode(node))
        } else {
            return super.visit(unPublicDeclNode(node))
        }
    }

    override func visit(_ node: EnumDeclSyntax) -> DeclSyntax {
        return super.visit(publicDeclNode(node))
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        return super.visit(publicDeclNode(node))
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        return super.visit(publicDeclNode(node))
    }
}

extension RePublicRewriter {
    private func publicSyntax<T: ModifierDeclSyntaxProtocol>(_ type: T.Type, lines: Int = 1) -> DeclModifierSyntax {
        let tokenKind: TokenKind
        switch mode {
        case .open:
            tokenKind = T.openAvaiable ? .openKeyword : .publicKeyword
        case .public:
            tokenKind = .publicKeyword
        }
        let token = SyntaxFactory.makeToken(tokenKind, presence: .present, leadingTrivia: Trivia(pieces: [.newlines(lines), .spaces(4)]), trailingTrivia: Trivia(pieces: [.spaces(1)]))
        return DeclModifierSyntax { $0.useName(token) }
    }

    private func unPublicDeclNode<T: ModifierDeclSyntaxProtocol>(_ node: T) -> T {
        var node = node
        if var modifiers = node.modifiers {
            let oldLeadingTrivia = node.leadingTrivia
            node = node.withoutLeadingTrivia()

            for (i, modify) in modifiers.enumerated() {
                if [TokenKind.publicKeyword, TokenKind.openKeyword].contains(modify.name.tokenKind) {
                    modifiers = modifiers.removing(childAt: i)
                }
            }
            node = node.withModifiers(modifiers)

            if let oldLeadingTrivia = oldLeadingTrivia {
                node = node.withLeadingTrivia(oldLeadingTrivia)
            }
        }
        return node
    }

    private func publicDeclNode<T: ModifierDeclSyntaxProtocol>(_ node: T) -> T {
        let oldLeadingTrivia = node.leadingTrivia
        var node = node.withoutLeadingTrivia()
        if var modifiers = node.modifiers {
            let whiteList: [TokenKind] = [.publicKeyword, .privateKeyword, .fileprivateKeyword, .openKeyword]
            let shouldFix = !modifiers.contains(where: { m in whiteList.contains(where: { $0 == m.name.tokenKind }) })
            for (i, modify) in modifiers.enumerated() {
                if modify.name.tokenKind == .internalKeyword {
                    modifiers = modifiers.removing(childAt: i)
                    break
                }
            }
            if shouldFix {
                modifiers = modifiers.inserting(publicSyntax(T.self), at: 0)
                node = node.withModifiers(modifiers)
            }
        } else {
            node = node.addModifier(publicSyntax(T.self))
        }
        if let oldLeadingTrivia = oldLeadingTrivia {
            node = node.withLeadingTrivia(oldLeadingTrivia)
        }
        return node
    }
}

extension ModifierDeclSyntaxProtocol {
    private var ifPrivateModifier: Bool {
        let list: [TokenKind] = [.privateKeyword, .fileprivateKeyword]
        if let modifiers = modifiers, modifiers.contains(where: { m in list.contains(where: { $0 == m.name.tokenKind }) }) {
            return true
        }
        return false
    }

    var shouldPublic: Bool {
        // Function/Closure
        if _syntaxNode.parentFunctionDeclSyntax != nil {
            return false
        }
        
        // Class/Struct/Enum, find one if marked `private`
        var prt: ModifierDeclSyntaxProtocol? = _syntaxNode.parentClassDeclSyntax
        while prt != nil {
            if prt?.ifPrivateModifier == true {
                return false
            }
            prt = prt?._syntaxNode.parentClassDeclSyntax
        }
        return true
    }
}

extension Syntax {
    // Function/Closure
    var parentFunctionDeclSyntax: SyntaxProtocol? {
        var prt: Syntax? = parent
        while prt != nil {
            if let r = prt?.as(FunctionDeclSyntax.self) {
                return r
            }
            if let r = prt?.as(ClosureSignatureSyntax.self) {
                return r
            }
            prt = prt?.parent
        }
        return nil
    }

    // Class/Struct/Enum
    var parentClassDeclSyntax: ModifierDeclSyntaxProtocol? {
        var prt: Syntax? = parent
        while prt != nil {
            if let r = prt?.as(ClassDeclSyntax.self) {
                return r
            }
            if let r = prt?.as(StructDeclSyntax.self) {
                return r
            }
            if let r = prt?.as(EnumDeclSyntax.self) {
                return r
            }
            prt = prt?.parent
        }
        return nil
    }
}
