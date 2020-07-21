//
//  GeneralViewController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/7.
//

import Cocoa
import Preferences
import HotKey
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
    
    private func updateView() {
        self.launchAtLoginBtn.setState(ConfigStorage.launchAtLogin)
        self.sendNotificationBtn.setState(ConfigStorage.sendNotification)
        self.updateHkBtn()
    }
    
    @IBAction func btnDidClick(_ sender: NSButton) {
        
        switch sender {
        case launchAtLoginBtn:
            ConfigStorage.launchAtLogin.toggle()
            
            let identifier = "com.LASER-Yi.CBLaunchHelper"
            
            let result = SMLoginItemSetEnabled(identifier as CFString, ConfigStorage.launchAtLogin)
            
            if !result {
                ConfigStorage.launchAtLogin = false
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
        case shortcutBtn:
            self.onHkBtnClick()
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
                        errorBox.messageText = "Cannot enable notification, please check your notification permission"
                        errorBox.beginSheetModal(for: window, completionHandler: nil)
                    }
                }
                
                self.updateView()
            }
        }
    }
    
    // MARK: -HotKey
    
    @IBOutlet weak var shortcutBtn: NSButton!
    
    @IBOutlet weak var hkStack: NSStackView!
    
    var isCancelShow: Bool {
        return cancelHkBtn.superview == self.hkStack
    }
    
    private lazy var cancelHkBtn: NSButton = {
        let button = NSButton()
        button.title = "X"
        button.alignment = .center
        button.bezelStyle = .recessed
        button.setButtonType(.momentaryPushIn)
        button.target = self
        button.action = #selector(onHkCancelClick)
        return button
    }()
    
    @objc func onHkCancelClick() {
        AppRuntime.shared.clearHotKey()
        self.updateHkBtn()
    }
    
    private func onHkBtnClick() {
        isRecording.toggle()
        
        if !isRecording {
            self.stopRecordHotKey()
        } else {
            self.updateHkBtn()
        }
    }
    
    private func updateHkBtn() {
        if isRecording {
            if let key = currentKey {
                self.shortcutBtn.title = KeyCombo(key: key, modifiers: self.currentModifier).description
            } else {
                self.shortcutBtn.title = self.currentModifier.description.count != 0 ? self.currentModifier.description : "..."
            }
        } else {
            if let combo = KeyCombo(dictionary: ConfigStorage.shortcut) {
                self.shortcutBtn.title = combo.description
                setCancelBtn(true)
            } else {
                self.shortcutBtn.title = "Record Shortcut"
                setCancelBtn(false)
            }
        }
    }
    
    private func setCancelBtn(_ show: Bool) {
        guard self.isCancelShow != show else { return }
        
        if show {
            self.hkStack.addView(self.cancelHkBtn, in: .trailing)
        } else {
            self.hkStack.removeView(self.cancelHkBtn)
        }
    }
    
    var isRecording = false
    
    var _currentKey: UInt16? = nil
    var currentKey: Key? {
        if let key = _currentKey {
            return Key(carbonKeyCode: UInt32(key))
        } else {
            return nil
        }
    }
    
    var currentModifier: NSEvent.ModifierFlags = .init()
    
    var currentCombo: KeyCombo? {
        if let key = currentKey {
            return KeyCombo(key: key, modifiers: self.currentModifier)
        } else {
            return nil
        }
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyUp(with: event)
        guard isRecording else { return }
        
        if let key = Key(carbonKeyCode: UInt32(event.keyCode)), key == Key.escape {
            self.stopRecordHotKey(cancel: true)
        } else {
            self._currentKey = event.keyCode
            self.updateHkBtn()
        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        guard isRecording else { return }
        
        let flags = event.modifierFlags
        
        if flags.description.count < currentModifier.description.count {
            // need stop
            self.stopRecordHotKey()
        } else {
            currentModifier = flags
            self.updateHkBtn()
        }
    }
    
    override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        guard isRecording else { return }
        
        if let key = _currentKey, key == event.keyCode {
            self.stopRecordHotKey()
        }
    }
    
    private func stopRecordHotKey(cancel: Bool = false) {
        self.isRecording = false
        
        if !cancel {
            // Setting up hot key here
            if let combo = self.currentCombo, vaildHotKey() && AppRuntime.shared.updateHotKey(combo: combo) {
                #if DEBUG
                print("Setting up new hotkey: \(combo)")
                #endif
            } else {
                let alert = NSAlert()
                alert.messageText = "Cannot set shortcut, maybe it's binding by another application"
                alert.runModal()
            }
        }
        
        self._currentKey = nil
        self.currentModifier = .init()
        self.updateHkBtn()
    }
    
    private func vaildHotKey() -> Bool {
        guard let combo = currentCombo, currentModifier.description.count != 0 else { return false }
        
        guard combo.isValid else { return false }
        
        let system = KeyCombo.systemKeyCombos() + KeyCombo.standardKeyCombos()
        
        return system.firstIndex(of: combo) == nil
    }
    
}
