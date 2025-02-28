//
//  ContentView.swift
//  TalkNative
//
//  Created by Lina on 2025/2/27.
//

import SwiftUI

struct ContentView: View {
    @State private var userMessage: String = ""
    @State private var chatbotResponse: String = "Here is your answer.."
    @State private var welcomeMessage: String = "Welcome to TalkNative!"

    var body: some View {
        VStack {
            Text(welcomeMessage)
                .padding()

            TextField("What do you want to say?", text: $userMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Send") {
                sendMessage()
            }
            .padding()
            
            Text(chatbotResponse)
                .padding()
        }
        .padding()
    }

    func sendMessage() {
        // chatbotResponse = "Processing: \(userMessage)" // Placeholder for now
        guard let url = URL(string: "http://localhost:8080/chat/message") else{
            chatbotResponse = "Invalid URL"
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["message": userMessage]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            chatbotResponse = "Error: \(error?.localizedDescription ?? "Unknown error")"
                        }
                        return
                    }
                    
                    if let responseText = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            chatbotResponse = responseText
                        }
                    }
                }.resume()
    }
}

#Preview {
    ContentView()
        
}
