// ComposeMessageView.swift
// Vue pour composer et programmer un message

import SwiftUI

struct ComposeMessageView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedContact: Contact?
    @State private var messageContent = ""
    @State private var selectedDate = Date().addingTimeInterval(3600) // +1h par défaut
    @State private var selectedAvatar: AnimatedAvatar?
    @State private var repeatMode: ScheduledMessage.RepeatMode = .none
    @State private var showAvatarPicker = false
    @State private var showContactPicker = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Section Contact
                Section(header: Text("Destinataire")) {
                    Button(action: { showContactPicker = true }) {
                        HStack {
                            if let contact = selectedContact {
                                ContactRow(contact: contact)
                            } else {
                                Label("Choisir un contact", systemImage: "person.circle")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Section Message
                Section(header: Text("Message")) {
                    TextEditor(text: $messageContent)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if messageContent.isEmpty {
                                    Text("Écris ton message ici...")
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                    
                    HStack {
                        Text("Caractères: \(messageContent.count)/500")
                            .font(.caption)
                            .foregroundColor(messageContent.count > 500 ? .red : .secondary)
                        Spacer()
                    }
                }
                
                // Section Avatar
                Section(header: Text("Avatar animé")) {
                    Button(action: { showAvatarPicker = true }) {
                        HStack {
                            if let avatar = selectedAvatar {
                                HStack {
                                    Image(systemName: "face.smiling")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                    
                                    VStack(alignment: .leading) {
                                        Text(avatar.name)
                                            .foregroundColor(.primary)
                                        Text(avatar.category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                Label("Choisir un avatar", systemImage: "sparkles")
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Section Programmation
                Section(header: Text("Programmation")) {
                    DatePicker(
                        "Date et heure",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    
                    Picker("Répétition", selection: $repeatMode) {
                        ForEach(ScheduledMessage.RepeatMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }
                
                // Bouton Envoyer
                Section {
                    Button(action: scheduleMessage) {
                        HStack {
                            Spacer()
                            Label("Programmer le message", systemImage: "clock.arrow.circlepath")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(!canSendMessage)
                    .foregroundColor(canSendMessage ? .white : .gray)
                    .listRowBackground(canSendMessage ? Color.blue : Color.gray.opacity(0.3))
                }
            }
            .navigationTitle("Nouveau message")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showContactPicker) {
                ContactPickerView(selectedContact: $selectedContact)
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerView(selectedAvatar: $selectedAvatar)
            }
            .alert("Message programmé !", isPresented: $showSuccessAlert) {
                Button("OK") {
                    resetForm()
                }
            } message: {
                Text("Ton message sera envoyé le \(selectedDate.formatted()).")
            }
        }
        .onAppear {
            checkPreselectedContact()
        }
    }
    
    private var canSendMessage: Bool {
        selectedContact != nil &&
        !messageContent.isEmpty &&
        messageContent.count <= 500 &&
        selectedAvatar != nil
    }
    
    private func scheduleMessage() {
        guard let contact = selectedContact,
              let avatar = selectedAvatar else { return }
        
        let message = ScheduledMessage(
            contactId: contact.id,
            content: messageContent,
            scheduledDate: selectedDate,
            avatarId: avatar.lottieFileName,
            repeatMode: repeatMode
        )
        
        dataStore.scheduleMessage(message)
        
        // Vibration de succès
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        showSuccessAlert = true
    }
    
    private func resetForm() {
        selectedContact = nil
        messageContent = ""
        selectedDate = Date().addingTimeInterval(3600)
        selectedAvatar = nil
        repeatMode = .none
    }
    
    private func checkPreselectedContact() {
        if let contactId = dataStore.selectedContactId,
           let contact = dataStore.getContact(by: contactId) {
            selectedContact = contact
            dataStore.selectedContactId = nil // Reset
        }
    }
}

// MARK: - Sélecteur de contacts
struct ContactPickerView: View {
    @Binding var selectedContact: Contact?
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataStore.contacts.filter { $0.isValidated }) { contact in
                    Button(action: {
                        selectedContact = contact
                        dismiss()
                    }) {
                        HStack {
                            ContactRow(contact: contact)
                            
                            if selectedContact?.id == contact.id {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choisir un contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Sélecteur d'avatars
struct AvatarPickerView: View {
    @Binding var selectedAvatar: AnimatedAvatar?
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: AnimatedAvatar.Category?
    
    var filteredAvatars: [AnimatedAvatar] {
        if let category = selectedCategory {
            return dataStore.avatars.filter { $0.category == category }
        }
        return dataStore.avatars
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filtres par catégorie
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryChip(
                            title: "Tous",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(AnimatedAvatar.Category.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Grille d'avatars
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                        ForEach(filteredAvatars) { avatar in
                            AvatarCard(
                                avatar: avatar,
                                isSelected: selectedAvatar?.id == avatar.id,
                                action: {
                                    selectedAvatar = avatar
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Choisir un avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Composants UI
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct AvatarCard: View {
    let avatar: AnimatedAvatar
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Placeholder pour l'animation
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 80)
                    .overlay(
                        Image(systemName: "face.smiling.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    )
                    .overlay(
                        Group {
                            if avatar.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .padding(4)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(5)
                            }
                        },
                        alignment: .topTrailing
                    )
                
                Text(avatar.name)
                    .font(.caption)
                    .lineLimit(1)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}