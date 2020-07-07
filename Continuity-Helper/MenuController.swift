//
//  MenuController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Foundation
import Cocoa
import Preferences

class MenuController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    private let window = NSWindow()
    let wrapper = WrapperController()
    
    let clipboardItem = NSMenuItem(title: "Copy to Clipboard", action: #selector(onClipboardItemClick), keyEquivalent: "")
    
    lazy var optionMenu: NSMenu = {
        let menu = NSMenu(title: "Options")
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "")
        
        let preferenceItem = NSMenuItem(title: "Preference...", action: #selector(onPreferenceItemClick), keyEquivalent: "")
        preferenceItem.target = self
        
        menu.addItem(clipboardItem)
        menu.addItem(.separator())
        menu.addItem(preferenceItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
        
        return menu
    }()
    
    override func awakeFromNib() {
        self.setup()
    }
    
    func setup() {
        if let button = statusItem.button, let image = NSImage(named: .init("StatusBarButton")) {
            button.image = image
            button.target = self
            button.action = #selector(onStatusItemClick)
        }
        // Window
        window.contentViewController = wrapper
        
        window.canHide = true
        window.hidesOnDeactivate = true
        window.collectionBehavior = .canJoinAllSpaces
    
        clipboardItem.target = self
    }
    
    
    @objc func onStatusItemClick() {
        if NSEvent.modifierFlags == .option {
            self.showOptionMenu()
        } else {
            self.showContinuityItem()
        }
    }
    
    // MARK: -Util
    func getActiveScreen() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) }
    }
    
    // MARK: -Options
    func showOptionMenu() {
        self.updateOptionMenu()
        statusItem.menu = optionMenu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    func updateOptionMenu() {
        clipboardItem.state = ConfigStorage.shared.copyToClipboard ? .on : .off
    }
    
    @objc func onClipboardItemClick() {
        ConfigStorage.shared.copyToClipboard.toggle()
    }
    
    @objc func onPreferenceItemClick() {
        let panels: [PreferencePane] = [GeneralViewController(), AboutViewController()]
        
        let prefWindow = PreferencesWindowController(preferencePanes: panels, style: .segmentedControl, animated: true, hidesToolbarForSingleItem: false)
        
        prefWindow.show()
    }
    
    // MARK: -Continuity
    func showContinuityItem() {
        guard let event = NSApplication.shared.currentEvent else { return }
        
        let menu = NSMenu(title: "Continuity")
        
        // Move the wrapper window to current screen
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.window.center()
            self.window.makeKeyAndOrderFront(nil)
            self.window.makeFirstResponder(self.wrapper)
            NSMenu.popUpContextMenu(menu, with: event, for: self.wrapper.view)
        }
    }
    
}
