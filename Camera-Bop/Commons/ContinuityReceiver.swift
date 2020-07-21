//
//  ReceiverManager.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/8.
//

import Foundation
import Cocoa

class ContinuityReceiver: NSObject {
    static let shared = ContinuityReceiver()
    
    enum RuntimeError: Error {
        case unsupportType
    }
    
    private(set) var clipboardUrl: URL? = nil
    
    func receive(data: Data, with ext: ReceiveExtension) {
        self.clear()
        
        if ConfigStorage.copyToClipboard {
            copyToClipboard(data: data, ext: ext)
        } else {
            // Create a Receive Window and place it there
            let preview = NSImage(data: data)!
            self.showReceiveWindow(with: preview, data: data, ext: ext)
        }
        
        // Deliver Notification if enabled
        if ConfigStorage.sendNotification {
            NotificationManager.shared.deliverRichNotification(with: "Copied to Clipboard", NSImage(data: data))
        }
    }
    
    private func copyToClipboard(data: Data, ext: ReceiveExtension) {
        let clip = NSPasteboard.general
        
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "HH:mm:ss"
        let title = formatter.string(from: .init())
        
        let tempUrl = AppRuntime.shared.temporaryUrl
        
        // TODO: Add More Type Support
        let path = tempUrl.appendingPathComponent("clipboard-\(title)").appendingPathExtension(ext.rawValue)
        
        do {
            try data.write(to: path)
            clipboardUrl = path
            clip.declareTypes([.init(rawValue: ext.rawValue)], owner: nil)
            clip.writeObjects([path as NSURL])
            
        } catch let error {
            if ConfigStorage.sendNotification {
                NotificationManager.shared.sendError(error)
            }
        }
    }
    
    func showReceiveWindow(with preview: NSImage, data: Data, ext: ReceiveExtension) {
        let window = ReceiveFileWindowController(windowNibName: "ReceiveFileWindowController")
        window.image = preview
        window.data = data
        window.ext = ext
        
        window.showWindow(nil)
    }
    
    func clear() {
        if let clipboard = self.clipboardUrl {
            try? FileManager.default.removeItem(at: clipboard)
        }
    }
}
