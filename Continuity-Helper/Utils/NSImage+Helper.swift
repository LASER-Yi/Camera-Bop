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
}
