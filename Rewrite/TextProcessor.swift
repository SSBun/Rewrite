//
//  TextProcessor.swift
//  Rewrite
//
//  Created by caishilin on 2024/9/26.
//

import Foundation
import OpenAI

class TextProcessor {
    static let shared = TextProcessor()
    
    var openAI: OpenAI
    
    init() {
        let host: String = UserDefaults.standard.string(forKey: "openAIBassURL") ?? "api.openai.com"
        let token: String = UserDefaults.standard.string(forKey: "openAIToken") ?? ""
        openAI = .init(configuration: .init(token: token, host: host))
    }
    
    func requestCompletion(_ prompt: String, system: String) async throws -> String {
        let query = ChatQuery(
            messages: [
                .system(.init(content: system)),
                .user(.init(content: .init(string: prompt)))
            ],
            model: .gpt4_o_mini
        )
        let result = try await openAI.chats(query: query)
        guard result.choices.count > 0 else {
            throw "No completion found."
        }
        guard let resultString = result.choices[0].message.content?.string else {
            throw "The returned completion hasn't a string content."
        }
        return resultString
    }
}


extension String: Error {}
