import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ContentView: View {
    @State private var messages: [Message] = [] // No chat initially
    @State private var userMessage: String = ""
    @State private var showChat = false // Show intro screen first


    var body: some View {
        VStack {
            // Top Navigation Bar
            topNavigationBar()

            if !showChat {
                // Initial Screen with App Icon and Description
                VStack {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .onAppear {
                            print("Icon loaded") // Debug if it's loading
                        }


                    Text("Helps improve English expression with native phrases.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)

                    Text("By Lina")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                }
                .padding(.top, 50)
                Spacer()
            } else {
                // Chat Messages
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Chat Input Bar
            chatInputBar()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    // MARK: - Top Navigation Bar
    private func topNavigationBar() -> some View {
        HStack {
            Image(systemName: "line.horizontal.3") // Menu icon
                .font(.title2)
            Spacer()
            Text("Talk Native")
                .font(.headline)
            Spacer()
            Image(systemName: "square.and.pencil") // Edit icon
                .font(.title2)
        }
        .padding()
    }

    // MARK: - Chat Input Bar
    @ViewBuilder
    private func chatInputBar() -> some View {
        HStack {
//            Button(action: {}) {
//                Image(systemName: "plus.circle")
//                    .font(.title2)
//            }

            TextField("Message", text: $userMessage)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .onSubmit {
                        sendMessage() // Automatically sends when "Enter" is pressed
                    }

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
            }
        }
        .padding()
    }

    // MARK: - Send Message Logic
    func sendMessage() {
        guard !userMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        showChat = true // Reveal chat UI

        messages.append(Message(text: userMessage, isUser: true)) // User message

        fetchChatbotResponse(for: userMessage) // Call API

        userMessage = "" // Clear input
    }

    // MARK: - Fetch AI Response
    func fetchChatbotResponse(for text: String) {
        guard let url = URL(string: "http://localhost:8080/chat/message") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["message": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }

            if let responseText = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    messages.append(Message(text: responseText, isUser: false)) // ChatGPT response
                }
            }
        }.resume()
    }

    // MARK: - Hide Keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Chat Bubble View
struct ChatBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            } else {
                Text(message.text)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
                Spacer()
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    ContentView()
}

