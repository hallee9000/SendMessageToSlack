//
//  Created by hallee on 2025/11/4.

import Foundation
import Combine

class SlackManager: ObservableObject {
    @Published var token: String = UserDefaults.standard.string(forKey: "SlackBotToken") ?? ""
    @Published var defaultChannel: String = UserDefaults.standard.string(forKey: "SlackDefaultChannel") ?? ""
    
    private let baseURL = "https://slack.com/api"
    private var cancellables = Set<AnyCancellable>()
    
    var isConfigured: Bool {
        !token.isEmpty && !defaultChannel.isEmpty
    }
    
    init() {
        // 监听 token 变化并保存
        $token
            .dropFirst()
            .sink { newToken in
                UserDefaults.standard.set(newToken, forKey: "SlackBotToken")
            }
            .store(in: &cancellables)
        
        // 监听默认 channel 变化并保存
        $defaultChannel
            .dropFirst()
            .sink { newChannel in
                UserDefaults.standard.set(newChannel, forKey: "SlackDefaultChannel")
            }
            .store(in: &cancellables)
    }
    
    func sendMessage(_ text: String, to channel: String? = nil) async throws {
        guard !token.isEmpty else {
            throw SlackError.missingToken
        }
        
        let targetChannel = channel ?? defaultChannel
        guard !targetChannel.isEmpty else {
            throw SlackError.missingChannel
        }
        
        let url = URL(string: "\(baseURL)/chat.postMessage")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "channel": targetChannel,
            "text": text
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SlackError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            throw SlackError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(SlackResponse.self, from: data)
        
        if !result.ok {
            throw SlackError.apiError(result.error ?? "Unknown error")
        }
    }
}

// 更新错误类型
enum SlackError: LocalizedError {
    case missingToken
    case missingChannel
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "Please enter your Slack Bot Token"
        case .missingChannel:
            return "Please specify a channel"
        case .invalidResponse:
            return "Invalid response from Slack API"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .apiError(let message):
            return "Slack API Error: \(message)"
        }
    }
}

struct SlackResponse: Codable {
    let ok: Bool
    let error: String?
    let ts: String?
}
