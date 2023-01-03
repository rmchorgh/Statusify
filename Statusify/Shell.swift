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

enum StatusifyRequest: String {
    case current = "currently-playing"
    case play = "play"
    case pause = "pause"
    case next = "next"
    case prev = "previous"
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
func requests(_ endpoint: StatusifyRequest) throws -> String {
    let home = FileManager.default.homeDirectoryForCurrentUser.absoluteString.dropFirst(7)
    return try runCommand(main: "\(home)/Documents/Statusify/Statusify/requests/statusify-requests", [endpoint.rawValue])
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
