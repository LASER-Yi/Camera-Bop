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
    
    func receive(image: NSImage) {
        self.clear()
        
        if ConfigStorage.shared.copyToClipboard {
            let clip = NSPasteboard.general
            
            let formatter: DateFormatter = .init()
            formatter.dateFormat = "HH:mm:ss"
            let title = formatter.string(from: .init())
            
            guard let ext = ImageExtension.init(rawValue: ConfigStorage.shared.imageExtension) else { return }
            
            // TODO: Add More Type Support
            let path = self.temporaryUrl.appendingPathComponent("clipboard-\(title)").appendingPathExtension(ext.rawValue)
            
            let data: Data?
            switch ext {
            case .png:
                data = image.pngRepresentation
            case .jpeg:
                data = image.jpegRepresentation
            case .tiff:
                data = image.tiffRepresentation
            }
            
            guard let imageData = data else { return }
            
            do {
                try imageData.write(to: path)
                clipboardUrl = path
                clip.declareTypes([.init(rawValue: ext.rawValue)], owner: nil)
                clip.writeObjects([path as NSURL])
                
                // Deliver Notification if enabled
                if ConfigStorage.shared.sendNotification {
                    
                    // create attachment for notification
                    let tempPath = temporaryUrl.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext.rawValue)
                    try imageData.write(to: tempPath)
                    NotificationManager.shared.sendClipboardNotify(with: tempPath)
                }
                
            } catch let error {
                NotificationManager.shared.sendError(error)
            }
            
        } else {
            // Create a Receive Window and place it there
            self.showReceiveWindow(with: image)
        }
    }
    
    func showReceiveWindow(with image: NSImage) {
        let window = ReceiveFileWindowController(windowNibName: "ReceiveFileWindowController")
        window.image = image
        
        window.showWindow(nil)
    }
    
    func clear() {
        if let clipboard = self.clipboardUrl {
            try? FileManager.default.removeItem(at: clipboard)
        }
    }
}
