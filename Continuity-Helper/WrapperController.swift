//
//  ViewController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/5.
//

import Cocoa

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
        guard let image = NSImage(pasteboard: pboard) else { return false }
        
        ContinuityReceiver.shared.receive(image: image)
        
        return true
    }

}

