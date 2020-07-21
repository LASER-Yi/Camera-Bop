//
//  ConfigStorage.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Foundation
import Cocoa
import HotKey

enum ReceiveExtension: String {
    case jpeg
    case png
    case pdf
}

class ConfigStorage {
    private init() {}
    
    @Config(key: "LaunchAtLogin", defaultVal: false) static var launchAtLogin
    
    @Config(key: "CopyToClipboard", defaultVal: false) static var copyToClipboard
    
    @Config(key: "SendNotification", defaultVal: false) static var sendNotification
    
    @Config(key: "ShortcutKey", defaultVal: [:]) static var shortcut: [String: Any];
}

@propertyWrapper
struct Config<T> {
    let key: String
    
    let defaultVal: T
    
    var wrappedValue: T {
        get {
            if let val = UserDefaults.standard.object(forKey: key) as? T {
                return val
            } else {
                UserDefaults.standard.set(defaultVal, forKey: key)
                return defaultVal
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
