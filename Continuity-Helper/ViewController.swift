//
//  ViewController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/5.
//

import Cocoa

class ViewController: NSViewController, NSServicesMenuRequestor {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?, returnType: NSPasteboard.PasteboardType?) -> Any? {
        if let pasteboardType = returnType,
            NSImage.imageTypes.contains(pasteboardType.rawValue) {
            return self  // This object can receive image data.
        } else {
            return super.validRequestor(forSendType: sendType, returnType: returnType)
        }
    }
    
    func readSelection(from pboard: NSPasteboard) -> Bool {
        guard pboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else { return false }
        guard let image = NSImage(pasteboard: pboard)?.tiffRepresentation else { return false }
        
        
        let clip = NSPasteboard.general
        clip.declareTypes([.tiff], owner: nil)
        clip.setData(image, forType: .tiff)
        return true
    }
    
    override func mouseDown(with event: NSEvent) {
        let menu = NSMenu(title: "Continuity")
        
        self.view.window?.makeFirstResponder(self)
        NSMenu.popUpContextMenu(menu, with: event, for: self.view)
    }

}

