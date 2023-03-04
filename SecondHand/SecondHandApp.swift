//
//  SecondHandApp.swift
//  SecondHand
//
//  Created by lemin on 3/2/23.
//

import SwiftUI
import Darwin

@main
struct SecondHandApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                checkAndEscape()
            }
        }
    }
    
    func checkAndEscape() {
    #if targetEnvironment(simulator)
            StatusManager.sharedInstance().setIsMDCMode(false)
    #else
        var supported = false
        var maybeSupported = false
        var needsTrollStore = false
        
        if #available(iOS 16.3, *) {
//            supported = false
        } else if #available(iOS 16.2, *) {
            if UserDefaults.standard.bool(forKey: "ShowUnsupported") {
                maybeSupported = true
            } else {
                supported = true
            }
        } else if #available(iOS 16.0, *) {
            supported = true
        } else if #available(iOS 15.7.2, *) {
//            supported = false
        } else if #available(iOS 15.0, *) {
            supported = true
        } else if #available(iOS 14.0, *) {
            supported = true
            needsTrollStore = true
        }
        
        if maybeSupported {
            UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported. Please close the app.", withButton: false)
            UIApplication.shared.confirmAlert(title: "Not Supported", body: "This version of iOS is likely not supported. Unless you know for certain that it is, please close the app.\n\nAre you certain this version is supported? The app will relaunch.", onOK: {
                UserDefaults.standard.set(false, forKey: "ShowUnsupported")
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    exit(0)
                }
            })
        } else if !supported {
            UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported. Please close the app.", withButton: false)
        } else {
            getRootFS(needsTrollStore: needsTrollStore)
        }
    #endif
    }
    
    func getRootFS(needsTrollStore: Bool) {
            do {
                // Check if application is entitled
                try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile"), includingPropertiesForKeys: nil)
                if UserDefaults.standard.bool(forKey: "ForceMDC") {
                    throw "Forced MDC"
                } else {
                    StatusManager.sharedInstance().setIsMDCMode(false)
                }
            } catch {
                if needsTrollStore {
                    UIApplication.shared.alert(title: "Use TrollStore", body: "You must install this app with TrollStore for it to work. Please close the app.", withButton: false)
                    return
                }
                // Use MacDirtyCOW to gain r/w
                grant_full_disk_access() { error in
                    if (error != nil) {
                        UIApplication.shared.alert(body: "\(String(describing: error?.localizedDescription))\nPlease close the app and retry.", withButton: false)
                        return
                    }
                    StatusManager.sharedInstance().setIsMDCMode(true)
                }
            }
            
            let fm = FileManager.default
            if fm.fileExists(atPath: "/var/mobile/Library/SpringBoard/statusBarOverridesEditing") {
                do {
                    try fm.removeItem(at: URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/statusBarOverridesEditing"))
                } catch {
                    UIApplication.shared.alert(body: "\(error)")
                }
            }
        }
}
