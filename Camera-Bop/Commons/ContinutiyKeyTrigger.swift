//
//  HotKeyManager.swift
//  Camera Bop
//
//  Created by LiangYi on 2020/7/15.
//

import Cocoa
import HotKey

func onHotkeyPressd() {
    let position = NSEvent.mouseLocation
    AppRuntime.shared.showContinuityItem(position)
}

class ContinutiyKeyTrigger {
    let hotkey: HotKey
    
    init?() {
        let dict = ConfigStorage.shortcut
        if let combo = KeyCombo(dictionary: dict) {
            hotkey = HotKey(keyCombo: combo)
            hotkey.keyUpHandler = onHotkeyPressd
        } else {
            return nil
        }
    }
}
