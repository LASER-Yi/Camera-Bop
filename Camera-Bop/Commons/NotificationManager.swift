//
//  NotificationManager.swift
//  Continuity-Helper
//
//  Created by LiangYi on 2020/7/8.
//

import Cocoa
import UserNotifications

class NotificationManager: NSObject {
    static let shared: NotificationManager = .init()
    
    fileprivate enum NotificationAction: String {
        case show
    }
    
    fileprivate enum NotificationCategory: String {
        case clipboard
    }
    
    public func initialize() {
        UNUserNotificationCenter.current().setNotificationCategories(.init(arrayLiteral: clipboardCategory))
        UNUserNotificationCenter.current().delegate = self
    }
    
    private lazy var clipboardCategory: UNNotificationCategory = {
        let showAction = UNNotificationAction(identifier: NotificationAction.show.rawValue, title: "Show", options: .foreground)
        
        return UNNotificationCategory(identifier: NotificationCategory.clipboard.rawValue, actions: [showAction], intentIdentifiers: [], options: .hiddenPreviewsShowSubtitle)
    }()
    
    func toggleNotification(_ callback: @escaping (_ result: Bool, _ error: Error?) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .provisional]) { (granted, error) in
            DispatchQueue.main.async {
                if let error = error {
                    ConfigStorage.sendNotification = false
                    callback(false, error)
                } else if !granted {
                    ConfigStorage.sendNotification = false
                    callback(false, nil)
                } else {
                    ConfigStorage.sendNotification.toggle()
                    callback(true, nil)
                }
            }
        }
    }
    
    func deliverRichNotification(with text: String, _ attachment: NSImage? = nil) {
        let notification = UNMutableNotificationContent()
        notification.title = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Camera Bop"
        notification.body = text
        notification.sound = .none
        notification.categoryIdentifier = NotificationCategory.clipboard.rawValue
        
        
        // Convert image to small jpeg
        let size = NSSize(width: 120, height: 120)
        let path = AppRuntime.shared.temporaryUrl.appendingPathComponent(UUID().description).appendingPathExtension(ReceiveExtension.jpeg.rawValue)
        
        if let item = attachment,
            let data = item.resize(size)?.jpegRepresentation,
            let _ = try? data.write(to: path),
            let attachment = try? UNNotificationAttachment(identifier: "image", url: path, options: nil){
                notification.attachments.append(attachment)
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func sendError(_ error: Error) {
        let notification = UNMutableNotificationContent()
        notification.title = "Error Occur"
        notification.body = error.localizedDescription
        notification.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case NotificationAction.show.rawValue:
            if let item = ContinuityReceiver.shared.clipboardUrl,
                let preview = NSImage(contentsOf: item),
                let data = try? Data(contentsOf: item),
                let ext = ReceiveExtension.init(rawValue: item.pathExtension){
                    ContinuityReceiver.shared.showReceiveWindow(with: preview, data: data, ext: ext)
            }
            break
        default:
            break
        }
        
        completionHandler()
    }
}
