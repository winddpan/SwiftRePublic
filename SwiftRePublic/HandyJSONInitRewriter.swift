//
//  HandyJSONInitRewriter.swift
//  SwiftRePublic
//
//  Created by PAN on 2020/12/25.
//

import Foundation
import SwiftSyntax

class HandyJSONInitRewriter: SyntaxRewriter {
    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        return super.visit(memberVisit(node))
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        return super.visit(memberVisit(node))
    }
}

private extension HandyJSONInitRewriter {
    private func memberVisit<T: MemberDeclSyntaxProtocol>(_ node: T) -> T {
        // if public
        guard node.isPublicModifier else {
            return node
        }

        // has Initializer
        guard !node.members.members.contains(where: { m in m.children.contains { $0.is(InitializerDeclSyntax.self) } }) else {
            return node
        }

        // if HandyJSON
        guard node.inheritanceClause?.children.contains(where: { $0.firstToken?.tokenKind.isHandyJSONToken == true }) == true else {
            return node
        }

        // generate: `public init() {}` `public required init() {}`
        var node = node
        var members = node.members

        let initNode = InitializerDeclSyntax.init { bulider in
            bulider.addModifier(DeclModifierSyntax {
                $0.useName(SyntaxFactory.makeToken(.publicKeyword, presence: .present, leadingTrivia: [.newlines(2), .spaces((node.leadingTrivia?.spacing ?? 0) + 4)], trailingTrivia: [.spaces(1)]))
            })
            if node is ClassDeclSyntax {
                bulider.addModifier(DeclModifierSyntax {
                    $0.useName(SyntaxFactory.makeToken(.identifier("required"), presence: .present, leadingTrivia: [], trailingTrivia: [.spaces(1)]))
                })
            }
            bulider.useParameters(ParameterClauseSyntax {
                $0.useLeftParen(SyntaxFactory.makeToken(.leftParen, presence: .present))
                $0.useRightParen(SyntaxFactory.makeToken(.rightParen, presence: .present))
            })
            bulider.useBody(CodeBlockSyntax {
                $0.useLeftBrace(SyntaxFactory.makeToken(.leftBrace, presence: .present, leadingTrivia: [.spaces(1)]))
                $0.useRightBrace(SyntaxFactory.makeToken(.rightBrace, presence: .present))
            })
            bulider.useInitKeyword(SyntaxFactory.makeToken(.initKeyword, presence: .present, leadingTrivia: []))
        }
        let newMember = MemberDeclListItemSyntax {
            $0.useDecl(DeclSyntax(initNode))
        }
        members = members.addMember(newMember)
        node = node.withMembers(members)

        return node
    }
}

private extension TokenKind {
    var isHandyJSONToken: Bool {
        switch self {
        case let .identifier(id) where ["HandyJSON", "JSONCodable", "NIMChatRoomSignal"].contains(id):
            return true
        default:
            return false
        }
    }
}
