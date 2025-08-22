// MessagesListView.swift
// Liste des messages reçus avec historique

import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var selectedMessage: ReceivedMessage?
    @State private var searchText = ""
    
    var filteredMessages: [ReceivedMessage] {
        if searchText.isEmpty {
            return dataStore.receivedMessages.sorted { $0.receivedAt > $1.receivedAt }
        }
        return dataStore.receivedMessages.filter { message in
            message.content.localizedCaseInsensitiveContains(searchText) ||
            dataStore.getContact(by: message.fromContactId)?.name.localizedCaseInsensitiveContains(searchText) ?? false
        }.sorted { $0.receivedAt > $1.receivedAt }
    }
    
    var body: some View {
        NavigationView {
            List {
                if filteredMessages.isEmpty {
                    EmptyMessagesView()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                } else {
                    ForEach(filteredMessages) { message in
                        MessageListRow(message: message)
                            .onTapGesture {
                                selectMessage(message)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteMessage(message)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    replayMessage(message)
                                } label: {
                                    Label("Rejouer", systemImage: "play.fill")
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher un message")
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedMessage) { message in
                MessageDetailView(message: message)
            }
            .onAppear {
                checkDeepLink()
            }
        }
    }
    
    private func selectMessage(_ message: ReceivedMessage) {
        dataStore.markMessageAsRead(message.id)
        selectedMessage = message
    }
    
    private func deleteMessage(_ message: ReceivedMessage) {
        withAnimation {
            dataStore.receivedMessages.removeAll { $0.id == message.id }
            dataStore.saveToUserDefaults()
        }
    }
    
    private func replayMessage(_ message: ReceivedMessage) {
        // Rejouer l'animation
        NotificationManager.shared.pendingMessage = message
        NotificationManager.shared.currentAvatarAnimation = message.avatarId
        NotificationManager.shared.showAnimationOverlay = true
    }
    
    private func checkDeepLink() {
        if deepLinkManager.showMessageDetail,
           let messageId = deepLinkManager.selectedMessageId,
           let message = dataStore.getReceivedMessage(by: messageId) {
            selectedMessage = message
            deepLinkManager.resetNavigation()
        }
    }
}

// MARK: - Vue vide
struct EmptyMessagesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.open")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Aucun message")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Les messages que tu reçois apparaîtront ici")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Row de message
struct MessageListRow: View {
    let message: ReceivedMessage
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        HStack(spacing: 12) {
            // Indicateur non lu
            Circle()
                .fill(message.isRead ? Color.clear : Color.blue)
                .frame(width: 8, height: 8)
            
            // Avatar contact
            if let contact = dataStore.getContact(by: message.fromContactId) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(contact.name.prefix(1)))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let contact = dataStore.getContact(by: message.fromContactId) {
                        Text(contact.name)
                            .font(.headline)
                            .fontWeight(message.isRead ? .regular : .bold)
                    }
                    
                    Spacer()
                    
                    Text(message.receivedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(message.isRead ? .secondary : .primary)
                    .lineLimit(2)
                
                // Badge avatar
                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                    Text("Avatar: \(message.avatarId)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Vue détail message
struct MessageDetailView: View {
    let message: ReceivedMessage
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var showReplayAnimation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header contact
                    if let contact = dataStore.getContact(by: message.fromContactId) {
                        VStack(spacing: 10) {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(String(contact.name.prefix(1)))
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                )
                            
                            Text(contact.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(contact.phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    // Contenu du message
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Message")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(message.content)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // Infos
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Reçu \(message.receivedAt.formatted())", systemImage: "clock")
                        Label("Avatar: \(message.avatarId)", systemImage: "sparkles")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(spacing: 15) {
                        Button(action: replayAnimation) {
                            Label("Rejouer l'animation", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: deleteMessage) {
                            Label("Supprimer le message", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Détail du message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func replayAnimation() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationManager.shared.pendingMessage = message
            NotificationManager.shared.currentAvatarAnimation = message.avatarId
            NotificationManager.shared.showAnimationOverlay = true
        }
    }
    
    private func deleteMessage() {
        dataStore.receivedMessages.removeAll { $0.id == message.id }
        dataStore.saveToUserDefaults()
        dismiss()
    }
}