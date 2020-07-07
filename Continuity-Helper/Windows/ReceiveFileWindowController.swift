//
//  ReceiveFileWindowController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Cocoa

class ReceiveFileWindowController: NSWindowController {

    @IBOutlet weak var imageView: DraggableImageView!
    
    var image: NSImage? = nil
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.imageView.image = self.image
        self.imageView.unregisterDraggedTypes()
        
        let formatter: DateFormatter = .init()
        
        formatter.dateFormat = "HH-mm-ss"
        
        let title = formatter.string(from: .init())
        
        self.imageView.title = title
        
        let ext = ConfigStorage.shared.imageExtension
        
        self.imageView.saveExtension = ImageExtension.init(rawValue: ext) ?? .png
        
        self.window?.title = "\(title).\(ext)"
        
        self.window?.center()
    }
    
}
