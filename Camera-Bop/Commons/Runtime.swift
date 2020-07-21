//
//  Runtime.swift
//  Camera Bop
//
//  Created by LiangYi on 2020/7/14.
//

import Cocoa
import Preferences
import HotKey

class AppRuntime {
    static let shared: AppRuntime = .init()
    
    private var trigger: ContinutiyKeyTrigger? = nil
    
    let window = NSWindow()
    let wrapper = WrapperController()
    
    lazy var temporaryUrl: URL = {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Receives")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }()
    
    public func initialize() {
        window.contentViewController = wrapper
        
        window.canHide = true
        window.hidesOnDeactivate = true
        window.collectionBehavior = .canJoinAllSpaces
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        trigger = ContinutiyKeyTrigger()
    }
    
    public func clearHotKey() {
        ConfigStorage.shortcut = [:]
        trigger = nil
    }
    
    public func updateHotKey(combo: KeyCombo) -> Bool {
        ConfigStorage.shortcut = combo.dictionary
        trigger = ContinutiyKeyTrigger()
        return trigger != nil
    }
    
    public func openPreferencePanel() {
        let panels: [PreferencePane] = [GeneralViewController(), AboutViewController()]
        
        let prefWindow = PreferencesWindowController(preferencePanes: panels, style: .segmentedControl, animated: true, hidesToolbarForSingleItem: false)
        
        prefWindow.show()
    }
    
    func showContinuityItem(_ pos: NSPoint? = nil) {
        let preEvent: NSEvent?
        if let position = pos {
            let locationInWindow = self.window.convertPoint(fromScreen: position)
            
            preEvent = NSEvent.mouseEvent(with: .leftMouseUp, location: locationInWindow, modifierFlags: .init(), timestamp: .init(), windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: 0, pressure: 0)
        } else {
            preEvent = NSApplication.shared.currentEvent
        }
        
        guard let event = preEvent else { return }
    
        let menu = NSMenu()
        
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
