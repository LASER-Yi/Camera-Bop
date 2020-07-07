//
//  NSButton+Helper.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Foundation
import Cocoa


extension NSButton {
    func setState(_ state: Bool) {
        self.state = state ? .on : .off
    }
}
