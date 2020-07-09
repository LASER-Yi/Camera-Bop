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
    
    private lazy var temporaryUrl: URL = {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Receives")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }()
    
    private(set) var clipboardUrl: URL? = nil
    
    func receive(data: Data, with ext: ReceiveExtension) {
        self.clear()
        
        if ConfigStorage.shared.copyToClipboard {
            let clip = NSPasteboard.general
            
            let formatter: DateFormatter = .init()
            formatter.dateFormat = "HH:mm:ss"
            let title = formatter.string(from: .init())
            
            // TODO: Add More Type Support
            let path = self.temporaryUrl.appendingPathComponent("clipboard-\(title)").appendingPathExtension(ext.rawValue)
            
            do {
                try data.write(to: path)
                clipboardUrl = path
                clip.declareTypes([.init(rawValue: ext.rawValue)], owner: nil)
                clip.writeObjects([path as NSURL])
                
                // Deliver Notification if enabled
                if ConfigStorage.shared.sendNotification {
                    
                    let tempPath: URL
                    if ext == .pdf {
                        // create attachment for notification
                        tempPath = temporaryUrl.appendingPathComponent(UUID().uuidString).appendingPathExtension(ReceiveExtension.jpeg.rawValue)
                        try NSImage(data: data)?.jpegRepresentation?.write(to: tempPath)
                    } else {
                        // create attachment for notification
                        tempPath = temporaryUrl.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext.rawValue)
                        try data.write(to: tempPath)
                    }
                    
                    NotificationManager.shared.sendClipboardNotify(with: tempPath)
                }
                
            } catch let error {
                NotificationManager.shared.sendError(error)
            }
            
        } else {
            // Create a Receive Window and place it there
            let preview = NSImage(data: data)!
            self.showReceiveWindow(with: preview, data: data, ext: ext)
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
