//
//  ViewController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/5.
//

import Cocoa
import UserNotifications

class WrapperController: NSViewController, NSServicesMenuRequestor {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?, returnType: NSPasteboard.PasteboardType?) -> Any? {
        if let pasteboardType = returnType,
            NSImage.imageTypes.contains(pasteboardType.rawValue) {
            return self
        } else {
            return super.validRequestor(forSendType: sendType, returnType: returnType)
        }
    }
    
    func readSelection(from pboard: NSPasteboard) -> Bool {
        guard let image = NSImage(pasteboard: pboard), pboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else { return false }
        
        
        if ConfigStorage.shared.copyToClipboard {
            let clip = NSPasteboard.general
            clip.declareTypes([.tiff, .png, .init(rawValue: kUTTypeJPEG as String)], owner: nil)
            
            
            // TODO: Add More Type Support
            clip.setData(image.pngRepresentation, forType: .png)
        } else {
            // Create a Receive Window and place it there
            let window = ReceiveFileWindowController(windowNibName: "ReceiveFileWindowController")
            window.image = image
            
            window.showWindow(nil)
        }
        
        
        // Deliver Notification if copy to clipboard
        if ConfigStorage.shared.sendNotification {
            self.sendNotification()
        }
        
        return true
    }
    
    func sendNotification() {
        let notification = NSUserNotification()
        notification.title = "Save to Clipboard"
        
        notification.deliveryDate = Date(timeIntervalSinceNow: .zero)
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }

}

