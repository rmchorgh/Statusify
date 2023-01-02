//
//  StatusifyApp.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import SwiftUI

@main
struct StatusifyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
