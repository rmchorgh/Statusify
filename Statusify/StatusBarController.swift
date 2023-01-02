//
//  StatusBarController.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    static private(set) var statusItem: NSStatusItem? = nil
    private(set) var popover: NSPopover
    
    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = .init()
        
        // MARK: - i dont know what sqlen looks like, maybe try variableLength
        
        Self.statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
     
        Self.updateSong()
    }
    
    static func updateSong(_ song: String = "Statusify") {
        if Self.statusItem != nil, let button = Self.statusItem!.button {
            button.action = #selector(showApp(sender: ))
            button.title = song
            button.target = self
            
            button.updateLayer()
        }
    }
    
    
    @objc
    func showApp(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(nil)
        }
        else {
            popover.show(relativeTo: Self.statusItem!.button!.bounds, of: Self.statusItem!.button!, preferredEdge: .maxY)
        }
    }
}
