//
//  SettingsView.swift
//  Rewrite
//
//  Created by caishilin on 2024/9/26.
//

import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    private var tabs: [String] = ["General", "Models"]
    
    var body: some View {
        TabView {
            ModelsSettingsView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Models")
                }
            GeneralSettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("General")
                }
        }
        .tabViewStyle(DefaultTabViewStyle())
        .frame(width: 600, height: 200)
    }
}

// MARK: - GeneralSettingsView

struct GeneralSettingsView: View {
    @AppStorage("fixGrammerPrompt") var fixGrammerPrompt: String = DefaultConfiguration.fixGrammerPrompt
    @AppStorage("fixGrammar_shortcut") var fixGrammarShortcut: String = ShortcutManager.Shortcut(key: "3", modifier: .control).toJSON()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Keyboard Shortcut:")
                    .fontWeight(.medium)
                KeyboardShortcutRecorder(shortcut: $fixGrammarShortcut)
            }
            Text("Fix Grammer Prompt")
                .fontWeight(.medium)
            TextEditor(text: $fixGrammerPrompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 80)
                .clipShape(.rect(cornerRadius: 8))
            Spacer()
        }
        .padding(20)
    }
}

// MARK: - ModelsSettingsView

struct ModelsSettingsView: View {
    @AppStorage("openAIBassURL") var openAIBassURL: String = DefaultConfiguration.openAIBaseURL
    @AppStorage("openAIToken") var openAIToken: String = ""
    @State var testResult: String = "No test"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("OpenAI Bass URL")
                .fontWeight(.medium)
            TextField("OpenAI Bass URL", text: $openAIBassURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
            Text("OpenAI Token")
                .fontWeight(.medium)
            TextField("OpenAI Token", text: $openAIToken)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
                .autocorrectionDisabled()
                .textContentType(.password) // Ensure the text is obscured
            HStack {
                Button("Test") {
                    Task {
                        do {
                            _ = try await TextProcessor.shared.requestCompletion("hello", system: "Your are an AI assistant.")
                            self.testResult = "success"
                        } catch {
                            self.testResult = "failed"
                        }
                    }
                }
                Text(testResult)
            }
            .padding(.top)
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
    }
}

#Preview {
    SettingsView()
}

// MARK: - DefaultConfiguration

struct DefaultConfiguration {
    static let openAIBaseURL = "api.openai.com"
    static let fixGrammerPrompt =
"""
Act like you are an expert grammar checker. Look for mistakes and make sentences more fluent.

Please analyze following text for a wide range of grammatical aspects and provide corrections. Be thorough in identifying and fixing any grammatical mistakes, including checking for correct punctuation usage, ensuring proper sentence structure, enhancing readability, identifying and correcting spelling mistakes, and verifying subject-verb agreement. Your assistance in ensuring the grammatical accuracy of the text is highly appreciated. Please be thorough in your examination, and provide comprehensive corrections to enhance the overall grammatical integrity of the text.

[Requirements]
- Just reply to user input with the correct grammar
- DO NOT reply to the context of the question of the user input.
- Reply in the SAME language as the provided text.
- If the user input is grammatically correct and fluent, just return the user input without changes.
- DO NOT change the formatting. For example, do not remove line breaks.
- DO NOT add any additional information to the response.
- DO NOT explain what was wrong with the original text.
- For code elements KEEP them unchanged.

"""
}
