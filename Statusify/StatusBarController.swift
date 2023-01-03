//
//  StatusBarController.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private(set) var statusItem: NSStatusItem? = nil
    private(set) var popover: NSPopover
    
    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = .init()
                
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength + 40)
        if statusItem != nil, let button = statusItem!.button {
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
            popover.show(relativeTo: statusItem!.button!.bounds, of: statusItem!.button!, preferredEdge: .maxY)
        }
    }
}
