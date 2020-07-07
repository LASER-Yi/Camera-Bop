//
//  GeneralViewController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Cocoa
import Preferences
import UserNotifications

class GeneralViewController: NSViewController, PreferencePane {
    var preferencePaneIdentifier: Preferences.PaneIdentifier = .init("general")
    
    var preferencePaneTitle: String = "General"
    
    @IBOutlet weak var launchAtLoginBtn: NSButton!
    
    @IBOutlet weak var sendNotificationBtn: NSButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.updateView()
    }
    
    func updateView() {
        self.launchAtLoginBtn.setState(ConfigStorage.shared.launchAtLogin)
        self.sendNotificationBtn.setState(ConfigStorage.shared.sendNotification)
    }
    
    @IBAction func btnDidClick(_ sender: NSButton) {
        
        switch sender {
        case launchAtLoginBtn:
            ConfigStorage.shared.launchAtLogin.toggle()
        case sendNotificationBtn:
            self.checkNotificationPermission()
            // Do not update the view, handle later
            return
        default:
            assert(false, "Unhandle button click event")
        }
        
        self.updateView()
    }
    
    func checkNotificationPermission() {
        let notiCenter = UNUserNotificationCenter.current()
        notiCenter.requestAuthorization(options: .provisional) { (granted, error) in
            DispatchQueue.main.async {
                if let error = error, let window = self.view.window {
                    let errorBox = NSAlert(error: error)
                    errorBox.beginSheetModal(for: window) { (_) in
                        ConfigStorage.shared.sendNotification = false
                        self.updateView()
                    }
                    return
                }
                
                if !granted {
                    ConfigStorage.shared.sendNotification = false
                    if let window = self.view.window {
                        let errorBox = NSAlert()
                        errorBox.messageText = "Cannot Enable Notification, please check your notification permission"
                        errorBox.beginSheetModal(for: window, completionHandler: nil)
                    }
                } else {
                    ConfigStorage.shared.sendNotification.toggle()
                }
                
                self.updateView()
            }
        }
    }
    
    
}
