//
//  Runtime.swift
//  Camera Bop
//
//  Created by LiangYi on 2020/7/14.
//

import Cocoa
import Preferences

class AppRuntime {
    static let shared: AppRuntime = .init()
    
    public func openPreferencePanel() {
        let panels: [PreferencePane] = [GeneralViewController(), AboutViewController()]
        
        let prefWindow = PreferencesWindowController(preferencePanes: panels, style: .segmentedControl, animated: true, hidesToolbarForSingleItem: false)
        
        prefWindow.show()
    }
}
