//
//  whiteboardApp.swift
//  whiteboard
//
//  Created by 孙斌 on 2025/8/17.
//

import SwiftUI

@main
struct whiteboardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(.clear)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
    }
}
