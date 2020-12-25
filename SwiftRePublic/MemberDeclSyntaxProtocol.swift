//
//  MemberDeclSyntaxProtocol.swift
//  SwiftRePublic
//
//  Created by PAN on 2020/12/25.
//

import Foundation
import SwiftSyntax

protocol MemberDeclSyntaxProtocol: ModifierDeclSyntaxProtocol {
    var inheritanceClause: TypeInheritanceClauseSyntax? { get }
    var members: MemberDeclBlockSyntax { get }
    func withMembers(_ newChild: MemberDeclBlockSyntax?) -> Self
}

extension StructDeclSyntax: MemberDeclSyntaxProtocol {}

extension ClassDeclSyntax: MemberDeclSyntaxProtocol {}
