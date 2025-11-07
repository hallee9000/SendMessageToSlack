//
//  Created by hallee on 2025/11/4.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var slackManager: SlackManager
    @Binding var showingSettings: Bool
    @State private var message = ""
    @State private var isSending = false
    @State private var isSent = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题栏
            HStack {
                Text("Send Message to Slack")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // 只在已配置的情况下显示关闭按钮
                if slackManager.isConfigured {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Settings")
                }
            }
            .padding(.bottom, 8)

            // 消息输入
            VStack(alignment: .leading, spacing: 4) {
                IconLabel(title: "Message", icon: "message.fill")
                TextEditor(text: $message)
                    .font(.system(size: 13))
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary, lineWidth: 2 / 3)
                            .fill(Color.secondary.gradient.opacity(0.075))
                            .opacity(0.3)
                    )
                    .frame(maxHeight: 80)
            }

            // 发送按钮
            Button(action: sendMessage) {
                HStack {
                    if isSending {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text(isSending ? "Sending..." : "Send Message")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSending || message.isEmpty)
            .keyboardShortcut(.return, modifiers: [.command])
            .controlSize(.large)
            
            if (isSent) {
                Text("Message is sent")
            }
            
            Divider()
            
            // 底部操作栏
            HStack {
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func sendMessage() {
        isSending = true

        Task {
            do {
                try await slackManager.sendMessage(message, to: slackManager.defaultChannel)
                await MainActor.run {
                    isSent = true
                    message = ""
                    isSending = false
                }
                try? await Task.sleep(for: .seconds(1))
                isSent = false
            } catch {
                await MainActor.run {
                    isSending = false
                }
            }
        }
    }
}

#Preview("ContentView") {
    // 定义一个临时的包装视图，它只负责管理 @State
    struct PreviewWrapper: View {
        @State private var isShowing = true

        var body: some View {
            // 将 @State 变量以绑定的形式($)传入
            // SettingsView 及其子视图现在可以从环境中获取 slackManager
            ContentView(showingSettings: $isShowing)
        }
    }
    
    // 在预览中：
    // 1. 创建 PreviewWrapper 实例
    // 2. 创建 SlackManager 实例并将其注入到环境中
    return PreviewWrapper()
        .frame(width: 320)
        .environmentObject(SlackManager()) // 在这里注入对象
}
