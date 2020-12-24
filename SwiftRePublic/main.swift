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
        print(result)
    } catch {
        print(error)
    }
}

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

let path = CommandLine.arguments[1]
let openMode = CommandLine.arguments[safe: 2]
let mode: RePublicRewriter.Mode = openMode != nil ? .open : .public
var isDir: ObjCBool = false
if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
    if !isDir.boolValue, path.lowercased().hasSuffix(".swift") {
        rePublic(path: path, mode: mode)
    } else {
        let directoryEnum = FileManager.default.enumerator(atPath: path)
        while let filePath = directoryEnum?.nextObject() as? String {
            let fullPath = path + "/" + filePath
            if fullPath.hasSuffix(".swift") {
                rePublic(path: fullPath, mode: mode)
            }
        }
    }
}
