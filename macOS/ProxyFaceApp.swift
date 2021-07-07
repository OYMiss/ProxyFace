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
            print("closing app")
            DisableSystemProxy()
            StopClash()
            print("closed")
        }
        
        print("starting")
        loadClashConfig()
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
