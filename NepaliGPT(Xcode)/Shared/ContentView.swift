
import SwiftUI
import AVKit
import CTScanText

struct ContentView: View {
        
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        chatListView
            .navigationTitle("Nepali GPT")
            .navigationBarTitleDisplayMode(.inline)
//            .font(.largeTitle)
        
    }
    
    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.messages) { message in
                            MessageRowView(message: message) { message in
                                Task { @MainActor in
                                    await vm.retry(message: message)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                }
                #if os(iOS) || os(macOS)
                Divider()
                bottomView("hello", proxy: proxy)
                Spacer()
                #endif
            }
            .onChange(of: vm.messages.last?.responseText) { _ in  scrollToBottom(proxy: proxy)
            }
        }
        .background(colorScheme == .light ? .white : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 0.5))
    }
    
    func bottomView(_: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
//edit packages

//            ScanTextField("Send message", text: $vm.inputMessage)
//                #if os(iOS)2
//                .frame(height: 55)
//                .background(.gray.opacity(0.1))
//                .cornerRadius(50)
//#endif
                
                
            
            TextField("Send message", text: $vm.inputMessage, axis: .vertical)

                #if os(iOS) || os(macOS)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(50)
                #endif
.focused($isTextFieldFocused)
.disabled(vm.isInteractingWithChatGPT)
                
                
            
            if vm.isInteractingWithChatGPT {
                DotLoadingView().frame(width: 60, height: 30)
            } else {
                Button {
                    Task { @MainActor in
                        isTextFieldFocused = false
                        scrollToBottom(proxy: proxy)
                        await vm.sendTapped()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 48))
                }
                
//                #if os(macOS)
//                .buttonStyle(.borderless)
//                .keyboardShortcut(.defaultAction)
//                .foregroundColor(.accentColor)
//                #endif
//                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView(vm: ViewModel(api: ChatGPTAPI(apiKey: "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")))
        }
    }
}
