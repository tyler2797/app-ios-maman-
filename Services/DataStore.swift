// DataStore.swift
// Gestionnaire de stockage local avec CoreData

import Foundation
import CoreData
import SwiftUI

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var contacts: [Contact] = []
    @Published var scheduledMessages: [ScheduledMessage] = []
    @Published var receivedMessages: [ReceivedMessage] = []
    @Published var avatars: [AnimatedAvatar] = AnimatedAvatar.defaultAvatars
    @Published var selectedContactId: UUID?
    @Published var userSettings = UserSettings()
    
    private let container: NSPersistentContainer
    private let userDefaults = UserDefaults.standard
    
    private init() {
        // Setup CoreData
        container = NSPersistentContainer(name: "KnockAvatar")
        
        // Description du modèle en code (sans .xcdatamodeld)
        let model = NSManagedObjectModel()
        
        // Entity Contact
        let contactEntity = NSEntityDescription()
        contactEntity.name = "ContactEntity"
        contactEntity.managedObjectClassName = "ContactEntity"
        
        let contactIdAttribute = NSAttributeDescription()
        contactIdAttribute.name = "id"
        contactIdAttribute.attributeType = .UUIDAttributeType
        contactIdAttribute.isOptional = false
        
        let contactNameAttribute = NSAttributeDescription()
        contactNameAttribute.name = "name"
        contactNameAttribute.attributeType = .stringAttributeType
        contactNameAttribute.isOptional = false
        
        let contactPhoneAttribute = NSAttributeDescription()
        contactPhoneAttribute.name = "phone"
        contactPhoneAttribute.attributeType = .stringAttributeType
        contactPhoneAttribute.isOptional = false
        
        contactEntity.properties = [contactIdAttribute, contactNameAttribute, contactPhoneAttribute]
        
        // Entity Message
        let messageEntity = NSEntityDescription()
        messageEntity.name = "MessageEntity"
        messageEntity.managedObjectClassName = "MessageEntity"
        
        let messageIdAttribute = NSAttributeDescription()
        messageIdAttribute.name = "id"
        messageIdAttribute.attributeType = .UUIDAttributeType
        messageIdAttribute.isOptional = false
        
        let messageContentAttribute = NSAttributeDescription()
        messageContentAttribute.name = "content"
        messageContentAttribute.attributeType = .stringAttributeType
        messageContentAttribute.isOptional = false
        
        let messageDateAttribute = NSAttributeDescription()
        messageDateAttribute.name = "date"
        messageDateAttribute.attributeType = .dateAttributeType
        messageDateAttribute.isOptional = false
        
        messageEntity.properties = [messageIdAttribute, messageContentAttribute, messageDateAttribute]
        
        model.entities = [contactEntity, messageEntity]
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                #if DEBUG
                print("❌ CoreData error: \(error.localizedDescription)")
                #endif
                // Fallback sur UserDefaults
                self.loadFromUserDefaults()
            } else {
                self.loadData()
            }
        }
        
        // Charger les settings
        loadSettings()
    }
    
    // MARK: - Chargement initial
    private func loadData() {
        // Charger depuis CoreData ou UserDefaults selon disponibilité
        loadFromUserDefaults()
        
        // Mode simulateur: ajouter des données de test
        #if targetEnvironment(simulator)
        setupSimulatorData()
        #endif
    }
    
    // MARK: - UserDefaults (fallback simple)
    private func loadFromUserDefaults() {
        do {
            if let contactsData = userDefaults.data(forKey: "contacts") {
                let decoded = try JSONDecoder().decode([Contact].self, from: contactsData)
                contacts = decoded.filter { isValidContact($0) }
            }
            
            if let messagesData = userDefaults.data(forKey: "scheduledMessages") {
                let decoded = try JSONDecoder().decode([ScheduledMessage].self, from: messagesData)
                scheduledMessages = decoded.filter { isValidMessage($0) }
            }
            
            if let receivedData = userDefaults.data(forKey: "receivedMessages") {
                let decoded = try JSONDecoder().decode([ReceivedMessage].self, from: receivedData)
                receivedMessages = decoded.filter { isValidReceivedMessage($0) }
            }
        } catch {
            #if DEBUG
            print("❌ Erreur chargement UserDefaults: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            
            let validContacts = contacts.filter { isValidContact($0) }
            let encodedContacts = try encoder.encode(validContacts)
            userDefaults.set(encodedContacts, forKey: "contacts")
            
            let validMessages = scheduledMessages.filter { isValidMessage($0) }
            let encodedMessages = try encoder.encode(validMessages)
            userDefaults.set(encodedMessages, forKey: "scheduledMessages")
            
            let validReceivedMessages = receivedMessages.filter { isValidReceivedMessage($0) }
            let encodedReceived = try encoder.encode(validReceivedMessages)
            userDefaults.set(encodedReceived, forKey: "receivedMessages")
            
        } catch {
            #if DEBUG
            print("❌ Erreur sauvegarde UserDefaults: \(error.localizedDescription)")
            #endif
        }
    }
    
    // MARK: - Settings
    private func loadSettings() {
        if let settingsData = userDefaults.data(forKey: "userSettings"),
           let decoded = try? JSONDecoder().decode(UserSettings.self, from: settingsData) {
            userSettings = decoded
        }
    }
    
    func saveSettings() {
        do {
            let encoded = try JSONEncoder().encode(userSettings)
            userDefaults.set(encoded, forKey: "userSettings")
        } catch {
            #if DEBUG
            print("❌ Erreur sauvegarde settings: \(error.localizedDescription)")
            #endif
        }
    }
    
    // MARK: - CRUD Contacts
    func addContact(_ contact: Contact) {
        guard isValidContact(contact), !contacts.contains(where: { $0.id == contact.id }) else {
            #if DEBUG
            print("⚠️ Contact invalide ou déjà existant")
            #endif
            return
        }
        
        contacts.append(contact)
        saveToUserDefaults()
    }
    
    func deleteContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        saveToUserDefaults()
    }
    
    func getContact(by id: UUID) -> Contact? {
        contacts.first { $0.id == id }
    }
    
    // MARK: - CRUD Messages
    func scheduleMessage(_ message: ScheduledMessage) {
        guard isValidMessage(message), !scheduledMessages.contains(where: { $0.id == message.id }) else {
            #if DEBUG
            print("⚠️ Message invalide ou déjà existant")
            #endif
            return
        }
        
        scheduledMessages.append(message)
        saveToUserDefaults()
        
        // Programmer la notification locale
        if let contact = getContact(by: message.contactId) {
            NotificationManager.shared.scheduleLocalNotification(message: message, contact: contact)
        }
    }
    
    func cancelMessage(_ message: ScheduledMessage) {
        scheduledMessages.removeAll { $0.id == message.id }
        NotificationManager.shared.cancelNotification(messageId: message.id.uuidString)
        saveToUserDefaults()
    }
    
    func addReceivedMessage(_ message: ReceivedMessage) {
        guard isValidReceivedMessage(message), !receivedMessages.contains(where: { $0.id == message.id }) else {
            #if DEBUG
            print("⚠️ Message reçu invalide ou déjà existant")
            #endif
            return
        }
        
        receivedMessages.append(message)
        saveToUserDefaults()
    }
    
    func getReceivedMessage(by id: String) -> ReceivedMessage? {
        receivedMessages.first { $0.id.uuidString == id }
    }
    
    func markMessageAsRead(_ messageId: UUID) {
        if let index = receivedMessages.firstIndex(where: { $0.id == messageId }) {
            receivedMessages[index].isRead = true
            saveToUserDefaults()
        }
    }
    
    // MARK: - Mode Simulateur
    #if targetEnvironment(simulator)
    private func setupSimulatorData() {
        // Ajouter des contacts de test
        if contacts.isEmpty {
            let testContacts = [
                Contact(name: "Alice", phone: "+33612345678", avatarId: "cat_happy", isValidated: true),
                Contact(name: "Bob", phone: "+33698765432", avatarId: "dog_cute", isValidated: true),
                Contact(name: "Charlie", phone: "+33655555555", avatarId: "heart_beat", isValidated: false)
            ]
            contacts = testContacts
        }
        
        // Ajouter un message de test programmé
        if scheduledMessages.isEmpty {
            let testMessage = ScheduledMessage(
                contactId: contacts[0].id,
                content: "Test message pour le simulateur ! 🎉",
                scheduledDate: Date().addingTimeInterval(30), // Dans 30 secondes
                avatarId: "birthday_cake",
                repeatMode: .none
            )
            scheduleMessage(testMessage)
        }
    }
    
    // Simuler la réception d'un message (pour tests)
    func simulateIncomingMessage() {
        guard let randomContact = contacts.randomElement() else { return }
        
        let messages = [
            "Salut ! Comment vas-tu ? 😊",
            "Joyeux anniversaire ! 🎂",
            "Tu me manques ❤️",
            "On se voit bientôt ?",
            "Bonne journée ! ☀️"
        ]
        
        let newMessage = ReceivedMessage(
            fromContactId: randomContact.id,
            content: messages.randomElement()!,
            avatarId: randomContact.avatarId
        )
        
        // Simuler une notification push
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.addReceivedMessage(newMessage)
            NotificationManager.shared.pendingMessage = newMessage
            NotificationManager.shared.currentAvatarAnimation = newMessage.avatarId
            NotificationManager.shared.showAnimationOverlay = true
        }
    }
    #endif
    
    // MARK: - Validation des données
    private func isValidContact(_ contact: Contact) -> Bool {
        return !contact.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !contact.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               contact.phone.count >= 10
    }
    
    private func isValidMessage(_ message: ScheduledMessage) -> Bool {
        return !message.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               message.scheduledDate > Date() &&
               !message.avatarId.isEmpty &&
               getContact(by: message.contactId) != nil
    }
    
    private func isValidReceivedMessage(_ message: ReceivedMessage) -> Bool {
        return !message.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !message.avatarId.isEmpty
    }
}