//
//  Created by hallee on 2025/11/4.

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var slackManager: SlackManager
    @Binding var showingSettings: Bool
    @State private var tempToken: String = ""
    @State private var tempChannel: String = ""
    @State private var isTestingConnection = false
    @State private var testResult = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // 标题栏
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // 只在已配置的情况下显示关闭按钮
                if slackManager.isConfigured {
                    Button(action: {
                        showingSettings = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 8)

            // Token 输入
            VStack(alignment: .leading, spacing: 4) {
                IconLabel(title: "Bot Token", icon: "key.fill")

                SecureField("xoxb-your-token", text: $tempToken)
                    .controlSize(.large)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Channel 输入
            VStack(alignment: .leading, spacing: 4) {
                IconLabel(title: "Channel ID", icon: "number.square.fill")

                TextField("C1234567890", text: $tempChannel)
                    .controlSize(.large)
                    .textFieldStyle(.roundedBorder)
            }
            
            // 帮助链接
            HStack {
                Link(destination: URL(string: "https://github.com/hallee9000/SendMessageToSlack")!) {
                    IconLabel(
                        title: "View toturial",
                        icon: "questionmark.circle.fill",
                        color: .blue
                    )
                        .font(.body)
                }
                .buttonStyle(.link)
                
                Spacer()
                
                if !tempToken.isEmpty {
                    Button(
                        testResult == ""
                            ? "Test Connection"
                            : (
                                testResult == "failed" ? "Test failed" : "Test successfully"
                            )
                    ) {
                        testConnection()
                    }
                        .disabled(isTestingConnection)
                }
            }

            // 按钮
            HStack {
                Spacer()
                if slackManager.isConfigured {
                    Button("Cancel") {
                        showingSettings = false
                    }
                    .keyboardShortcut(.escape)
                    .controlSize(.large)
                } else {
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .foregroundColor(.red)
                    .controlSize(.large)
                }
                Button("Save") {
                    saveSettings()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(tempToken.isEmpty || tempChannel.isEmpty)
                .controlSize(.large)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            tempToken = slackManager.token
            tempChannel = slackManager.defaultChannel
        }
    }

    private func saveSettings() {
        slackManager.token = tempToken
        slackManager.defaultChannel = tempChannel
        
        if slackManager.isConfigured {
            showingSettings = false
        }
    }
    
    private func testConnection() {
        isTestingConnection = true

        // 创建临时的 manager 来测试
        let testManager = SlackManager()
        testManager.token = tempToken
        testManager.defaultChannel = tempChannel
        
        Task {
            do {
                try await testManager.sendMessage("Test message from Slack Sender", to: tempChannel)
                await MainActor.run {
                    testResult = "success"
                    isTestingConnection = false
                }
            } catch {
                await MainActor.run {
                    testResult = "failed"
                    isTestingConnection = false
                }
            }
        }
    }
}

#Preview("可交互的预览") {
    // 定义一个临时的包装视图，它只负责管理 @State
    struct PreviewWrapper: View {
        @State private var isShowing = true

        var body: some View {
            // 将 @State 变量以绑定的形式($)传入
            // SettingsView 及其子视图现在可以从环境中获取 slackManager
            SettingsView(showingSettings: $isShowing)
        }
    }
    
    // 在预览中：
    // 1. 创建 PreviewWrapper 实例
    // 2. 创建 SlackManager 实例并将其注入到环境中
    return PreviewWrapper()
        .frame(width: 320)
        .environmentObject(SlackManager()) // 在这里注入对象
}
