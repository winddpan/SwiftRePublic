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
        if node.shouldItemPublic {
            return super.visit(publicDeclNode(node))
        } else {
            return super.visit(unPublicDeclNode(node))
        }
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        if node.shouldItemPublic {
            return super.visit(publicDeclNode(node))
        } else {
            return super.visit(unPublicDeclNode(node))
        }
    }

    override func visit(_ node: ProtocolDeclSyntax) -> DeclSyntax {
        return super.visit(publicDeclNode(node))
    }

    override func visit(_ node: TypealiasDeclSyntax) -> DeclSyntax {
        return super.visit(publicDeclNode(node))
    }

    override func visit(_ node: InitializerDeclSyntax) -> DeclSyntax {
        if node.shouldItemPublic {
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
    var shouldItemPublic: Bool {
        guard let parent = parent else {
            return false
        }

        if parent.getParent(VariableDeclSyntax.self) != nil {
            return false
        }
        if parent.getParent(FunctionDeclSyntax.self) != nil {
            return false
        }
        if parent.getParent(ClosureSignatureSyntax.self) != nil {
            return false
        }
        if parent.getParent(InitializerDeclSyntax.self) != nil {
            return false
        }
        if parent.getParent(ProtocolDeclSyntax.self) != nil {
            return false
        }
        if parent.getParent(SubscriptDeclSyntax.self) != nil {
            return false
        }

        if let p = parent.getParent(ClassDeclSyntax.self), p.isPublicModifier {
            return true
        }
        if let p = parent.getParent(StructDeclSyntax.self), p.isPublicModifier {
            return true
        }
        if let p = parent.getParent(EnumDeclSyntax.self), p.isPublicModifier {
            return true
        }
        
        return false
    }
}


extension Syntax {
    func getParent<T: SyntaxProtocol>(_ type: T.Type) -> T? {
        var node: Syntax? = self
        while node != nil {
            if let r = node?.as(T.self) {
                return r
            }
            node = node?.parent
        }
        return nil
    }
}
