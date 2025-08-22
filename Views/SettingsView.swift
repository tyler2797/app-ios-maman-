// SettingsView.swift
// Paramètres de l'application

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showPermissionsInfo = false
    @State private var showAbout = false
    @State private var showDebugMode = false
    
    var body: some View {
        NavigationView {
            Form {
                // Section Notifications
                Section(header: Text("Notifications")) {
                    Toggle("Activer les sons", isOn: $dataStore.userSettings.enableSound)
                        .onChange(of: dataStore.userSettings.enableSound) { _ in
                            dataStore.saveSettings()
                        }
                    
                    Toggle("Activer les vibrations", isOn: $dataStore.userSettings.enableVibration)
                        .onChange(of: dataStore.userSettings.enableVibration) { _ in
                            dataStore.saveSettings()
                        }
                    
                    Toggle("Mode discret", isOn: $dataStore.userSettings.discretMode)
                        .onChange(of: dataStore.userSettings.discretMode) { _ in
                            dataStore.saveSettings()
                        }
                    
                    Text("En mode discret, les animations n'apparaissent pas automatiquement")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Section Apparence
                Section(header: Text("Apparence")) {
                    Picker("Thème", selection: $dataStore.userSettings.theme) {
                        ForEach(UserSettings.AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .onChange(of: dataStore.userSettings.theme) { _ in
                        dataStore.saveSettings()
                        updateAppearance()
                    }
                }
                
                // Section Autorisations
                Section(header: Text("Autorisations système")) {
                    Button(action: checkNotificationPermissions) {
                        HStack {
                            Label("Notifications", systemImage: "bell")
                            Spacer()
                            Image(systemName: getNotificationStatus())
                                .foregroundColor(getNotificationStatusColor())
                        }
                    }
                    
                    Button(action: { showPermissionsInfo = true }) {
                        Label("Gérer les autorisations", systemImage: "gear")
                    }
                }
                
                // Section Données
                Section(header: Text("Données")) {
                    HStack {
                        Text("Messages reçus")
                        Spacer()
                        Text("\(dataStore.receivedMessages.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Messages programmés")
                        Spacer()
                        Text("\(dataStore.scheduledMessages.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Contacts")
                        Spacer()
                        Text("\(dataStore.contacts.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: clearAllData) {
                        Label("Effacer toutes les données", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // Section Debug (Simulateur)
                #if targetEnvironment(simulator)
                Section(header: Text("Mode développeur")) {
                    Toggle("Mode debug", isOn: $showDebugMode)
                    
                    if showDebugMode {
                        Button(action: { dataStore.simulateIncomingMessage() }) {
                            Label("Simuler message entrant", systemImage: "envelope.badge")
                        }
                        
                        Button(action: testLocalNotification) {
                            Label("Tester notification locale", systemImage: "bell.badge")
                        }
                        
                        Button(action: printDeviceToken) {
                            Label("Afficher token APNs", systemImage: "key")
                        }
                    }
                }
                #endif
                
                // Section À propos
                Section {
                    Button(action: { showAbout = true }) {
                        HStack {
                            Text("À propos")
                            Spacer()
                            Text("Version 1.0")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Réglages")
            .sheet(isPresented: $showPermissionsInfo) {
                PermissionsInfoView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .alert("Effacer les données", isPresented: .constant(false)) {
                Button("Annuler", role: .cancel) {}
                Button("Effacer", role: .destructive) {
                    performDataClear()
                }
            } message: {
                Text("Cette action supprimera tous les messages, contacts et paramètres. Elle est irréversible.")
            }
        }
    }
    
    // MARK: - Helpers
    private func updateAppearance() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        switch dataStore.userSettings.theme {
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        case .auto:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                NotificationManager.shared.requestAuthorization()
            } else if settings.authorizationStatus == .denied {
                // Ouvrir les réglages
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    private func getNotificationStatus() -> String {
        "questionmark.circle" // Simplifié pour le MVP
    }
    
    private func getNotificationStatusColor() -> Color {
        .orange // Simplifié pour le MVP
    }
    
    private func clearAllData() {
        // Afficher l'alerte de confirmation
    }
    
    private func performDataClear() {
        dataStore.contacts.removeAll()
        dataStore.scheduledMessages.removeAll()
        dataStore.receivedMessages.removeAll()
        dataStore.userSettings = UserSettings()
        dataStore.saveSettings()
        dataStore.saveToUserDefaults()
    }
    
    #if targetEnvironment(simulator)
    private func testLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Toc toc, tu as un message"
        content.body = "Test de notification locale"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func printDeviceToken() {
        if let token = NotificationManager.shared.deviceToken {
            print("📱 Token APNs: \(token)")
        } else {
            print("❌ Aucun token APNs disponible")
        }
    }
    #endif
}

// MARK: - Vue Permissions
struct PermissionsInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Pour fonctionner correctement, KnockAvatar a besoin de certaines autorisations :")
                            .font(.subheadline)
                        
                        PermissionRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            description: "Pour recevoir les messages programmés"
                        )
                        
                        PermissionRow(
                            icon: "person.2.fill",
                            title: "Contacts",
                            description: "Pour sélectionner les destinataires (optionnel)"
                        )
                    }
                    .padding(.vertical)
                }
                
                Section {
                    Button(action: openSettings) {
                        Label("Ouvrir les réglages système", systemImage: "gear")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Autorisations")
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
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Vue À propos
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("KnockAvatar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Envoyez des messages avec des avatars animés qui frappent à la porte de vos amis !")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 10) {
                    Text("© 2024 KnockAvatar")
                    Text("Fait avec ❤️ en Swift")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
            }
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
}