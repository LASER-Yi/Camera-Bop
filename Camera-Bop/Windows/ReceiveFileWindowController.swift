//
//  ReceiveFileWindowController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Cocoa

class ReceiveFileWindowController: NSWindowController {
    
    static func create() -> ReceiveFileWindowController {
        return ReceiveFileWindowController(windowNibName: "ReceiveFileWindowController")
    }

    @IBOutlet weak var imageView: DraggableImageView!
    
    var image: NSImage!
    
    var ext: ReceiveExtension!
    
    var data: Data!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.imageView.image = self.image
        self.imageView.ext = ext
        self.imageView.data = data
        
        self.imageView.unregisterDraggedTypes()
        
        let formatter: DateFormatter = .init()
        
        formatter.dateFormat = "HH-mm-ss"
        
        let title = formatter.string(from: .init())
        
        self.imageView.title = title
        
        self.window?.title = "\(title).\(ext.rawValue)"
        
        self.window?.center()
    }
    
}
