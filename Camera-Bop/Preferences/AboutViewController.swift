//
//  AboutViewController.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/6.
//

import Cocoa
import Preferences

class AboutViewController: NSViewController, PreferencePane {
    var preferencePaneIdentifier: Preferences.PaneIdentifier = .init(rawValue: "about")
    
    var preferencePaneTitle: String = "About"
    
    @IBOutlet weak var versionLabel: NSTextField!
    
    var versionText: String {
        var text = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String  {
            
            text = "Version \(version) (\(build))"
        }
        
        return text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.versionLabel.stringValue = versionText
    }
    
    // MARK: -Buttons
    
    @IBOutlet weak var sourceBtn: NSButton!
    
    @IBOutlet weak var issueBtn: NSButton!
    
    @IBAction func openUrlAction(_ sender: NSButton) {
        
        let link: URL?
        
        switch sender {
        case issueBtn:
            link = URL(string: "https://github.com/LASER-Yi/Camera-Bop/issues")
        default:
            link = URL(string: "https://github.com/LASER-Yi/Camera-Bop")
        }
        
        guard let url = link else {return}
        
        NSWorkspace.shared.open(url)
    }

    
}
