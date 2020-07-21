//
//  MenuController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Cocoa
import Preferences
import HotKey

class MenuController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        if let button = statusItem.button, let image = NSImage(named: .init("StatusBarButton")) {
            button.image = image
            button.target = self
            button.action = #selector(onStatusItemClick(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    
        clipboardItem.target = self
    }
    
    
    @objc func onStatusItemClick(sender: NSStatusBarButton) {
        guard let event = NSApplication.shared.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            self.showOptionMenu()
        } else {
            AppRuntime.shared.showContinuityItem()
        }
    }
    
    // MARK: -Util
    func getActiveScreen() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) }
    }
    
    // MARK: -Options Menus
    
    let clipboardItem = NSMenuItem(title: "Copy to Clipboard", action: #selector(onClipboardItemClick), keyEquivalent: "C")
    
    lazy var optionMenu: NSMenu = {
        let menu = NSMenu(title: "Options")
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "Q")
        
        let preferenceItem = NSMenuItem(title: "Preference...", action: #selector(onPreferenceItemClick), keyEquivalent: ",")
        preferenceItem.target = self
        
        menu.addItem(clipboardItem)
        menu.addItem(.separator())
        menu.addItem(preferenceItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
        
        return menu
    }()
    
    func showOptionMenu() {
        self.updateOptionMenu()
        statusItem.menu = optionMenu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    func updateOptionMenu() {
        clipboardItem.state = ConfigStorage.copyToClipboard ? .on : .off
    }
    
    @objc func onClipboardItemClick() {
        ConfigStorage.copyToClipboard.toggle()
    }
    
    @objc func onPreferenceItemClick() {
        AppRuntime.shared.openPreferencePanel()
    }
    
}
