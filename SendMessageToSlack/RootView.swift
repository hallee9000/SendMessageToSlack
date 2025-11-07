//
//  Created by hallee on 2025/11/4.

import SwiftUI

struct RootView: View {
    @EnvironmentObject var slackManager: SlackManager
    @State private var showingSettings = false
    
    var body: some View {
        Group {
            if !slackManager.isConfigured || showingSettings {
                // 未配置或显示设置时，显示设置视图
                SettingsView(showingSettings: $showingSettings)
                    .environmentObject(slackManager)
            } else {
                // 已配置，显示主界面
                ContentView(showingSettings: $showingSettings)
                    .environmentObject(slackManager)
            }
        }
        .frame(width: 320)
        .fixedSize()
    }
}
