//
//  StatusBarController.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private(set) var statusItem: NSStatusItem
    private(set) var popover: NSPopover
    
    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = .init()
        
        // MARK: - i dont know what sqlen looks like, maybe try variableLength
        
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Statusify")
            button.action = #selector(showApp(sender: ))
            button.target = self
        }
    }
    
    @objc
    func showApp(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(nil)
        }
        else {
            popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
        }
    }
}
