//
//  main.swift
//  SwiftRePublic
//
//  Created by PAN on 2020/12/23.
//

import Foundation
import SwiftSyntax

func rePublic(path: String, mode: RePublicRewriter.Mode) {
    do {
        let url = URL(fileURLWithPath: path)
        let sourceFile = try SyntaxParser.parse(url)
        let result = RePublicRewriter(mode: mode).visit(sourceFile)
        if result.contentLength.utf8Length > 0 {
            try result.description.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        }
    } catch {
        print("rePublic", error)
    }
}

func handyJSONInit(path: String) {
    do {
        let url = URL(fileURLWithPath: path)
        let sourceFile = try SyntaxParser.parse(url)
        let result = HandyJSONInitRewriter().visit(sourceFile)
        if result.contentLength.utf8Length > 0 {
            try result.description.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        }
    } catch {
        print("handyJSONInit", error)
    }
}

let path = CommandLine.arguments[safe: 1]
let openMode = CommandLine.arguments[safe: 2]
let mode: RePublicRewriter.Mode = openMode != nil ? .open : .public
var isDir: ObjCBool = false
if let path = path, FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
    if !isDir.boolValue, path.lowercased().hasSuffix(".swift") {
        print(path)
        rePublic(path: path, mode: mode)
        handyJSONInit(path: path)
    } else {
        let directoryEnum = FileManager.default.enumerator(atPath: path)
        while let filePath = directoryEnum?.nextObject() as? String {
            let fullPath = path + "/" + filePath
            if fullPath.hasSuffix(".swift") {
                print(fullPath)
                rePublic(path: fullPath, mode: mode)
                handyJSONInit(path: fullPath)
            }
        }
    }
}
