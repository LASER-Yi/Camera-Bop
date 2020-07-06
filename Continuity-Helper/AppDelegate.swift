//
//  AppDelegate.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/5.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    let window = NSWindow()
    let wrapper = WrapperController()
    
    let menu = NSMenu(title: "Continuity")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button, let image = NSImage(named: .init("StatusBarButton")) {
            button.image = image
            button.target = self
            button.action = #selector(onStatusItemClick)
        }
        // Window
        window.contentViewController = wrapper
        
        window.canHide = true
        window.hidesOnDeactivate = true
        
        // Menu
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "Q")
        menu.addItem(quitItem)
    }
    
    func getActiveScreen() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) }
    }
    
    @objc func onStatusItemClick() {
        guard let event = NSApplication.shared.currentEvent else { return }
        
        window.makeKeyAndOrderFront(self)
        window.makeFirstResponder(wrapper)
        
        if let screen = self.getActiveScreen() {
            // set window to center
            let x: CGFloat = ( NSWidth(screen.frame) - NSWidth(window.frame) ) / 2.0
            let y: CGFloat = ( NSHeight(screen.frame) - NSHeight(window.frame) ) / 2.0
            window.setFrame(NSMakeRect(x, y, 0, 0), display: true)
        }
        
        NSMenu.popUpContextMenu(menu, with: event, for: wrapper.view)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

}

