//
//  ConfigStorage.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Foundation
import Cocoa

enum ImageExtension: String {
    case jpeg
    case png
    case tiff
}

class ConfigStorage {
    static let shared = ConfigStorage()
    private init() {}
    
    @Config(key: "LaunchAtLogin", defaultVal: false) var launchAtLogin
    
    @Config(key: "CopyToClipboard", defaultVal: true) var copyToClipboard
    
    @Config(key: "SendNotification", defaultVal: false) var sendNotification
    
    @Config(key: "ImageExtension", defaultVal: ImageExtension.png.rawValue) var imageExtension
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
