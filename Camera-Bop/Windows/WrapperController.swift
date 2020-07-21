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
        
        let ext: ReceiveExtension
        let data: Data

        if pboard.canReadItem(withDataConformingToTypes: [kUTTypePNG as String]) {
            ext = .png
            data = pboard.data(forType: .png)!
        } else if pboard.canReadItem(withDataConformingToTypes: [kUTTypeJPEG as String]) {
            ext = .jpeg
            data = pboard.data(forType: .init(kUTTypeJPEG as String))!
        } else if pboard.canReadItem(withDataConformingToTypes: [kUTTypePDF as String]) {
            ext = .pdf
            data = pboard.data(forType: .pdf)!
        } else {
            return false
        }
        
        ContinuityReceiver.shared.receive(data: data, with: ext)
        
        return true
    }

}

