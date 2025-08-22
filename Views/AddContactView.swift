// AddContactView.swift
// Vue pour ajouter un nouveau contact

import SwiftUI
import Contacts

struct AddContactView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var contactName = ""
    @State private var contactPhone = ""
    @State private var selectedAvatar = AnimatedAvatar.defaultAvatars.first!
    @State private var showContactPicker = false
    @State private var showValidationAlert = false
    @State private var contactsAccessDenied = false
    
    var body: some View {
        NavigationView {
            Form {
                // Section Informations
                Section(header: Text("Informations du contact")) {
                    TextField("Nom", text: $contactName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Téléphone", text: $contactPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    Button(action: requestContactsAccess) {
                        Label("Importer depuis les contacts", systemImage: "person.crop.circle")
                            .foregroundColor(.blue)
                    }
                }
                
                // Section Avatar par défaut
                Section(header: Text("Avatar par défaut")) {
                    Picker("Avatar", selection: $selectedAvatar) {
                        ForEach(AnimatedAvatar.defaultAvatars) { avatar in
                            HStack {
                                Image(systemName: "face.smiling")
                                Text(avatar.name)
                            }
                            .tag(avatar)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Section Validation
                Section(header: Text("Validation mutuelle")) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Comment ça marche ?")
                                .fontWeight(.medium)
                        }
                        
                        Text("Pour éviter le spam, les deux contacts doivent s'ajouter mutuellement. Une fois validé, vous pourrez vous envoyer des messages.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !contactPhone.isEmpty && isValidPhone(contactPhone) {
                            Button(action: sendValidationRequest) {
                                Label("Envoyer une demande de validation", systemImage: "paperplane")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ajouter un contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        addContact()
                    }
                    .disabled(!canAddContact)
                }
            }
            .alert("Accès refusé", isPresented: $contactsAccessDenied) {
                Button("OK") {}
                Button("Ouvrir Réglages") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("L'accès aux contacts est nécessaire pour importer un contact. Vous pouvez l'autoriser dans les réglages.")
            }
            .alert("Demande envoyée", isPresented: $showValidationAlert) {
                Button("OK") {}
            } message: {
                Text("Une demande de validation a été envoyée à \(contactName). Une fois acceptée, vous pourrez échanger des messages.")
            }
        }
    }
    
    private var canAddContact: Bool {
        !contactName.isEmpty && isValidPhone(contactPhone)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        // Validation basique du numéro
        let cleaned = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        return cleaned.count >= 10
    }
    
    private func addContact() {
        let newContact = Contact(
            name: contactName,
            phone: formatPhone(contactPhone),
            avatarId: selectedAvatar.lottieFileName,
            isValidated: false // Sera validé après acceptation mutuelle
        )
        
        dataStore.addContact(newContact)
        
        // Vibration de succès
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        dismiss()
    }
    
    private func formatPhone(_ phone: String) -> String {
        // Nettoyer et formater le numéro
        var cleaned = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        // Ajouter le + si absent
        if !cleaned.hasPrefix("+") && !cleaned.hasPrefix("0") {
            cleaned = "+\(cleaned)"
        } else if cleaned.hasPrefix("0") {
            // Remplacer 0 par +33 pour la France
            cleaned = "+33" + String(cleaned.dropFirst())
        }
        
        return cleaned
    }
    
    private func requestContactsAccess() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.showContactPicker = true
                } else {
                    self.contactsAccessDenied = true
                }
            }
        }
    }
    
    private func sendValidationRequest() {
        // Simuler l'envoi d'une demande de validation
        // En production, cela enverrait une notification au serveur
        showValidationAlert = true
        
        // Marquer temporairement comme "en attente"
        // Le contact sera validé quand l'autre utilisateur acceptera
    }
}