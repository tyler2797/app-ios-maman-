// ContentView.swift
// Vue principale avec TabView et gestion des overlays

import SwiftUI
import Lottie

struct ContentView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @StateObject private var dataStore = DataStore.shared
    
    var body: some View {
        ZStack {
            // Vue principale avec tabs
            TabView(selection: $deepLinkManager.activeTab) {
                HomeView()
                    .tabItem {
                        Label("Accueil", systemImage: "house.fill")
                    }
                    .tag(DeepLinkManager.Tab.home)
                
                MessagesListView()
                    .tabItem {
                        Label("Messages", systemImage: "envelope.fill")
                    }
                    .tag(DeepLinkManager.Tab.messages)
                    .badge(dataStore.receivedMessages.filter { !$0.isRead }.count)
                
                ComposeMessageView()
                    .tabItem {
                        Label("Composer", systemImage: "square.and.pencil")
                    }
                    .tag(DeepLinkManager.Tab.compose)
                
                SettingsView()
                    .tabItem {
                        Label("Réglages", systemImage: "gear")
                    }
                    .tag(DeepLinkManager.Tab.settings)
            }
            .environmentObject(dataStore)
            
            // Overlay pour l'animation d'avatar
            if notificationManager.showAnimationOverlay {
                AvatarAnimationOverlay()
                    .environmentObject(notificationManager)
                    .environmentObject(dataStore)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    private func setupInitialState() {
        // Demander les autorisations
        notificationManager.checkNotificationStatus()
        
        // Reset badge
        notificationManager.resetBadge()
        
        // Mode simulateur: bouton de test
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("🔧 Mode simulateur activé - Messages de test disponibles")
        }
        #endif
    }
}

// MARK: - Vue Accueil
struct HomeView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showAddContact = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HeaderSection()
                    
                    // Contacts validés
                    ContactsSection(contacts: dataStore.contacts.filter { $0.isValidated })
                    
                    // Messages programmés
                    ScheduledMessagesSection(messages: dataStore.scheduledMessages.filter { !$0.isDelivered })
                    
                    // Mode simulateur
                    #if targetEnvironment(simulator)
                    SimulatorSection()
                    #endif
                }
                .padding()
            }
            .navigationTitle("KnockAvatar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddContact = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showAddContact) {
                AddContactView()
            }
        }
    }
}

// MARK: - Section Header
struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Toc toc, quelqu'un frappe !")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Envoyez des messages avec des avatars animés")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
    }
}

// MARK: - Section Contacts
struct ContactsSection: View {
    let contacts: [Contact]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contacts")
                .font(.headline)
            
            if contacts.isEmpty {
                Text("Aucun contact validé")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
            } else {
                ForEach(contacts) { contact in
                    ContactRow(contact: contact)
                }
            }
        }
    }
}

// MARK: - Row Contact
struct ContactRow: View {
    let contact: Contact
    
    var body: some View {
        HStack {
            // Avatar placeholder
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(contact.name.prefix(1)))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading) {
                Text(contact.name)
                    .fontWeight(.medium)
                Text(contact.phone)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if contact.isValidated {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Section Messages Programmés
struct ScheduledMessagesSection: View {
    let messages: [ScheduledMessage]
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Messages programmés")
                .font(.headline)
            
            if messages.isEmpty {
                Text("Aucun message programmé")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
            } else {
                ForEach(messages) { message in
                    ScheduledMessageRow(message: message)
                }
            }
        }
    }
}

// MARK: - Row Message Programmé
struct ScheduledMessageRow: View {
    let message: ScheduledMessage
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let contact = dataStore.getContact(by: message.contactId) {
                    Text("Pour: \(contact.name)")
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text(message.scheduledDate, style: .relative)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Text(message.content)
                .font(.subheadline)
                .lineLimit(2)
            
            if message.repeatMode != .none {
                Label(message.repeatMode.rawValue, systemImage: "repeat")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Section Simulateur (Tests)
#if targetEnvironment(simulator)
struct SimulatorSection: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        VStack(spacing: 10) {
            Text("🔧 Mode Simulateur")
                .font(.headline)
                .foregroundColor(.orange)
            
            Button(action: {
                dataStore.simulateIncomingMessage()
            }) {
                Label("Simuler réception message", systemImage: "envelope.badge")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text("Tap pour tester l'animation d'avatar")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
}
#endif