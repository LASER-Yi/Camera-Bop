//
//  GeneralViewController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Cocoa
import Preferences
import ServiceManagement

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
            
            let identifier = "com.LASER-Yi.CBLaunchHelper"
            
            let result = SMLoginItemSetEnabled(identifier as CFString, ConfigStorage.shared.launchAtLogin)
            
            if !result {
                ConfigStorage.shared.launchAtLogin = false
                if let window = self.view.window {
                    let errorBox = NSAlert()
                    errorBox.messageText = "Launch at Login is Unavailable"
                    errorBox.beginSheetModal(for: window)
                }
            }
            
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
        
        NotificationManager.shared.toggleNotification { (result, error) in
            DispatchQueue.main.async {
                if let error = error, let window = self.view.window {
                    let errorBox = NSAlert(error: error)
                    errorBox.beginSheetModal(for: window)
                } else if !result {
                    if let window = self.view.window {
                        let errorBox = NSAlert()
                        errorBox.messageText = "Cannot Enable Notification, please check your notification permission"
                        errorBox.beginSheetModal(for: window, completionHandler: nil)
                    }
                }
                
                self.updateView()
            }
        }
    }
    
    
}
