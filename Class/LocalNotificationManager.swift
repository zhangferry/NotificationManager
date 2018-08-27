//
//  LocalNotificationManager.swift
//  LocalNotificationManager
//
//  Created by 张飞 on 2018/8/23.
//  Copyright © 2018年 zhangferry. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationManager {
    class NotificationContent {
        var identifier: String!///request identifier
        var title: String?
        var subtitle: String?
        var body: String?
        var badge: Int = 0
        var userInfo: [AnyHashable : Any] = [:]
        var components: NotificationComponents?
        
    }
    struct NotificationComponents {
        var hour: Int = 0
        var minute: Int = 0
        var type: FrequencyType = .once
    }
    ///frequency
    enum FrequencyType: Int {
        case once = 0
        case everyday
        case weekday
        case weekends
    }
    
    static let shared = LocalNotificationManager()
    
    ///This block may be executed on a background thread
    func requestAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound], completionHandler: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            completionHandler(granted)
        }
    }
    ///This block may be executed on a background thread.
    func getNotificationAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            completionHandler(setting.authorizationStatus)
        }
    }
    /// add local notification with custom param
    func addLocalNotification(content: NotificationContent) {
        if content.identifier == nil {
            fatalError("NotificationContent.identifier must have a value")
        }
        let theContent = UNMutableNotificationContent()
        theContent.badge = content.badge as NSNumber
        theContent.userInfo = content.userInfo
        if let body = content.body {
            theContent.body = body
        }
        if let title = content.title {
            theContent.title = title
        }
        if let subTitle = content.subtitle {
            theContent.subtitle = subTitle
        }
        if let components = content.components {
            var theComponents = DateComponents()
            theComponents.hour = components.hour
            theComponents.minute = components.minute
            self.addLocalNotification(identifier: content.identifier, content: theContent, components: theComponents, type: components.type)
        } else {
            let request = UNNotificationRequest.init(identifier: content.identifier, content: theContent, trigger: nil)
            UNUserNotificationCenter.current().add(request) { (error) in
                if error == nil {
                    print("local notification: [\(request.identifier)] add success")
                }
            }
        }
        
    }
    ///add local notification with system param
    func addLocalNotification(identifier: String, content: UNMutableNotificationContent, components: DateComponents, type: FrequencyType) {
        
        switch type {
        case .once:
            self.addSingleLocalNotification(with: identifier, content: content, components: components, repeats: false)
        case .everyday:
            self.addSingleLocalNotification(with: identifier, content: content, components: components, repeats: true)
        case .weekday:
            self.addWeekdayLocalNotification(with: identifier, weekdays: [2,3,4,5,6], content: content, components: components, repeats: true)
        case .weekends:
            self.addWeekdayLocalNotification(with: identifier, weekdays: [1,7], content: content, components: components, repeats: true)
        }
    }
    ///private fucntion: add weekdayNotification 1:Sunday，2:Monday...7:Saturday
    private func addWeekdayLocalNotification(with identifier: String, weekdays: [Int], content: UNMutableNotificationContent, components: DateComponents, repeats: Bool) {
        for weekday in weekdays {
            var comp = components
            comp.weekday = weekday
            self.addSingleLocalNotification(with: "\(identifier)\(weekday)", content: content, components: comp, repeats: repeats)
        }
    }
    ///private function: add singleLocalNotification
    private func addSingleLocalNotification(with identifier: String, content: UNMutableNotificationContent, components: DateComponents, repeats: Bool) {
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: components, repeats: repeats)
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error == nil {
                print("local notification: [\(request.identifier)] add success")
            }
        }
    }
    /// remove all notificatoin
    func removeAllNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    /// remove some notification with request identifier
    func removeNotification(with identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
