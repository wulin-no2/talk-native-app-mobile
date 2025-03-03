import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var userMessage: String = ""
    @State private var showChat = false
    @State private var scrollProxy: ScrollViewProxy?
    @State private var isUserAtBottom = true

    var body: some View {
        VStack {
            topNavigationBar()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        if !showChat {
                            VStack {
                                Image("icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)

                                Text("Helps improve English expression with native phrases.")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 10)

                                Text("By Lina")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                            }
                            .padding(.top, 80)
                            .transition(.opacity)
                        }

                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                    .onAppear {
                        self.scrollProxy = proxy
                    }
                }
                .simultaneousGesture(DragGesture().onChanged { _ in hideKeyboard() })

            }

            chatInputBar()
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onTapGesture {
            hideKeyboard()
        }
        
    }

    private func topNavigationBar() -> some View {
        HStack {
            Image(systemName: "line.horizontal.3")
                .font(.title2)
            Spacer()
            Text("Talk Native 🥳")
                .font(.headline)
            Spacer()
            Image(systemName: "square.and.pencil")
                .font(.title2)
        }
        .padding()
    }

    @ViewBuilder
    private func chatInputBar() -> some View {
        VStack(spacing: 0) {
            HStack {
                TextField("What do you wanna say?", text: $userMessage)
                    .padding(8 )
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            //.background(Color.white)
            .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 20))
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: -3)
        }
    }

    // Custom Shape for Rounded Top Corners
    struct RoundedCornersShape: Shape {
        var corners: UIRectCorner
        var radius: CGFloat

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }



    func sendMessage() {
        guard !userMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        showChat = true

        let userMsg = Message(text: userMessage, isUser: true)
        messages.append(userMsg)
        
        // Hide keyboard after sending message
        hideKeyboard()

        DispatchQueue.main.async {
            scrollProxy?.scrollTo(userMsg.id, anchor: .bottom)
        }

        fetchChatbotResponse(for: userMessage)

        userMessage = ""
    }

    func fetchChatbotResponse(for text: String) {
        guard let url = URL(string: "https://talknative.online/chat/message") else {
            print("Failed to create URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["message": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network request failed: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No response data from server")
                return
            }

            if let responseText = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    let botMsg = Message(text: responseText, isUser: false)
                    messages.append(botMsg)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let proxy = scrollProxy {
                            proxy.scrollTo(botMsg.id, anchor: .bottom)
                        } else {
                            print("scrollProxy is nil")
                        }
                    }
                }
            } else {
                print("Failed to parse response")
            }
        }.resume()
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

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

