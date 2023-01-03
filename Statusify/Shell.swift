//
//  Shell.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import Foundation

enum StatusifyError: Error {
    case emptyEndpoint
}

@discardableResult
func brew(_ command: String...) throws -> String {
    return try runCommand(main: "/usr/local/bin/brew", command)
}

@discardableResult
func keyServer() throws -> String {
    let home = FileManager.default.homeDirectoryForCurrentUser.absoluteString.dropFirst(7)
    return try runCommand(main: "\(home)/Documents/Statusify/Statusify/localserver/statusify-auth", [])
}

@discardableResult
func requests(_ endpoint: String) throws -> String {
    guard !endpoint.isEmpty else {
        throw StatusifyError.emptyEndpoint
    }
    let home = FileManager.default.homeDirectoryForCurrentUser.absoluteString.dropFirst(7)
    return try runCommand(main: "\(home)/Documents/Statusify/Statusify/requests/statusify-requests", [endpoint])
}

@discardableResult
func runCommand(main: String, _ args: [String]) throws -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    
    task.arguments = args
    
    task.executableURL = URL(fileURLWithPath: main)
    task.standardInput = nil

    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}
