//
//  AppDelegate.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static var popover = NSPopover()
    var statusBar: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.popover.contentViewController = NSHostingController(rootView: ContentView())
        
        Self.popover.behavior = .semitransient
        
        statusBar = StatusBarController(Self.popover)
    }
}
