//
//  ProxyFaceApp.swift
//  Shared
//
//  Created by oymiss on 27/6/2021.
//

import SwiftUI
import Combine

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }
    }
}

extension View {
    func visiableWhen(_ visiable: Bool) -> some View {
        if visiable {
            return AnyView(self)
        } else {
            return AnyView(self.hidden())
        }
    }
    
    func existWhen(_ exist: Bool) -> some View {
        if exist {
            return AnyView(self)
        } else {
            return AnyView(EmptyView())
        }
    }
}


@main
struct ProxyFaceApp: App {
    init() {
        #if os(macOS)
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            // terminating
            NSLog("closing app")
            DisableSystemProxy()
            StopClash()
            NSLog("closed")
        }
        
        #if !DEBUG
        let home = FileManager.default.homeDirectoryForCurrentUser
        let logurl = home.appendingPathComponent("/Library/Logs/ProxyFace.log")
        freopen(logurl.path.cString(using: String.Encoding.ascii)!, "a+", stderr)
        freopen(logurl.path.cString(using: String.Encoding.ascii)!, "a+", stdout)
        #endif
        
        NSLog("starting")
        loadClashConfig()
        loadUserConfig()
        StartClash()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            SidebarView()
            #endif
        }
    }
}
