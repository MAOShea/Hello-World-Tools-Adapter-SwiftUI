//
//  ContentView.swift
//  Hello World
//
//  Created by mike on 04/07/2025.
//

import SwiftUI
import Foundation
import ChatCore

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel(aiService: ToolsEnabledAIService(), disableToolCallDetection: true, disableStructuredContent: true)
    @State private var splitPosition: CGFloat = 0.5
    
    var body: some View {
        VSplitView {
            // Top conversation history (readonly)
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if viewModel.conversationHistory.isEmpty {
                            VStack(spacing: 16) {
                                Text("Start a conversation with your local AI...")
                                    .foregroundColor(.secondary)
                                
/*                                 Button("🚀 Boot Up as Widget Designer") {
                                    viewModel.bootUpWithRole(firstPrompt: Constants.Prompts.humanRolePrompt)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(viewModel.isLoading)
 */                            }
                            .padding()
                        } else {
                            ForEach(viewModel.conversationHistory) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("AI is thinking...")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading)
                            .id("loading")
                        }
                    }
                    .padding()
                    .onChange(of: viewModel.conversationHistory.count) { oldValue, newValue in
                        if let lastMessage = viewModel.conversationHistory.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isLoading) { oldValue, newValue in
                        if newValue {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("loading", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .background(Color(NSColor.windowBackgroundColor))
            .border(Color.gray.opacity(0.3), width: 1)
            
            // Bottom section with user input and toolbar
            VStack(spacing: 0) {
                // User input field (editable)
                TextEditor(text: $viewModel.userInput)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .border(Color.gray.opacity(0.3), width: 1)
                    .onKeyPress(.return) {
                        if NSEvent.modifierFlags.contains(.shift) {
                            // Shift+Enter: allow line break
                            return .ignored
                        } else {
                            // Enter: send message
                            print("🔧 DEBUG: Enter key pressed")
                            print("🔧 DEBUG: promptStrategy = \(viewModel.promptStrategy)")
                            
                            print("🔧 DEBUG: Calling sendMessage")
                            viewModel.sendMessage()
                            return .handled
                        }
                    }
                
                // Toolbar aligned with lower edge
                HStack {
                    Spacer()
                    
                    Button("Clear") {
                        viewModel.clearConversation()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isLoading)
                    
                    Button("Send") {
                        viewModel.sendMessage()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .border(Color.gray.opacity(0.3), width: 1)
            }
        }
        .alert("Hello World!", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .sheet(isPresented: $viewModel.showingSaveDialog) {
            SaveWidgetView(viewModel: viewModel)
        }
        .alert("File Operation", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = viewModel.lastError {
                Text(error)
            } else {
                Text("Widget file saved successfully!")
            }
        }
    }
}

struct SaveWidgetView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save Widget File")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("A JavaScript widget file has been generated. Choose where to save it.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Preview:")
                    .fontWeight(.medium)
                
                ScrollView {
                    Text(viewModel.javascriptToSave)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Save File...") {
                    viewModel.saveWidgetFile()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}

#Preview {
    ContentView()
}
