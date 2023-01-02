//
//  Shell.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import Foundation

@discardableResult
func safeShell(_ command: String...) throws -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    
    task.arguments = command
    
    task.executableURL = URL(fileURLWithPath: "/usr/local/bin/brew")
    task.standardInput = nil

    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}
