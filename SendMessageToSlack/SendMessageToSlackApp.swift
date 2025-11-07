//
//  Created by hallee on 2025/11/4.

import SwiftUI

@main
struct SlackMenuBarApp: App {
    @StateObject private var slackManager = SlackManager()
    
    var body: some Scene {
        // 菜单栏窗口
        MenuBarExtra {
            RootView()
                .environmentObject(slackManager)
        } label: {
            Label("Slack Sender", systemImage: "number.square.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
