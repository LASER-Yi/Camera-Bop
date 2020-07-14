//
//  AppDelegate.swift
//  LauncherHelper
//
//  Created by LiangYi on 2020/7/14.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let mainAppId = "com.LASER-Yi.CameraBop"
        
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppId }.isEmpty
        
        if !isRunning {
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast(3)
            components.append("MacOS")
            components.append("Camera Bop")

            let newPath = NSString.path(withComponents: components)

            NSWorkspace.shared.launchApplication(newPath)
        }
        
        NSApp.terminate(nil)
    }
}

