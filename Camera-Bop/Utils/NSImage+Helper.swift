//
//  NSImage+Helper.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Foundation
import Cocoa

extension NSImage {
    var jpegRepresentation: Data? {
        guard let tiffData = self.tiffRepresentation else { return nil }
        let bitmapImageRep = NSBitmapImageRep(data: tiffData)
        return bitmapImageRep?.representation(using: .jpeg, properties: [:])
    }
    
    var pngRepresentation: Data? {
        guard let tiffData = self.tiffRepresentation else { return nil }
        let bitmapImageRep = NSBitmapImageRep(data: tiffData)
        return bitmapImageRep?.representation(using: .png, properties: [:])
    }
    
    func resize(_ size: NSSize) -> NSImage? {
        if self.isValid {
            
            let widthScale = size.width / self.size.width
            let heightScale = size.height / self.size.height
            let scale = min(widthScale, heightScale)
            
            let trueSize = NSSize(width: self.size.width * scale, height: self.size.height * scale)
            
            return NSImage(size: trueSize, flipped: false) { (rect) -> Bool in
                self.draw(in: rect)
                return true
            }
        } else {
            return nil
        }
    }
}
