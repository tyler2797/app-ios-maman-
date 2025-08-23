// DataModels.swift
// Modèles de données pour KnockAvatar

import Foundation
import SwiftUI

// MARK: - Contact
struct Contact: Identifiable, Codable {
    var id: UUID
    var name: String
    var phone: String
    var avatarId: String
    var isValidated: Bool = false // Contact mutuellement validé
    var createdAt: Date = Date()
    
    init(id: UUID = UUID(), name: String, phone: String, avatarId: String, isValidated: Bool = false) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        self.avatarId = avatarId
        self.isValidated = isValidated
    }
    
    var isValid: Bool {
        return !name.isEmpty && phone.count >= 10 && !avatarId.isEmpty
    }
}

// MARK: - Message programmé
struct ScheduledMessage: Identifiable, Codable {
    var id: UUID
    var contactId: UUID
    var content: String
    var scheduledDate: Date
    var avatarId: String
    var repeatMode: RepeatMode = .none
    var isDelivered: Bool = false
    var createdAt: Date = Date()
    
    init(id: UUID = UUID(), contactId: UUID, content: String, scheduledDate: Date, avatarId: String, repeatMode: RepeatMode = .none) {
        self.id = id
        self.contactId = contactId
        self.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.scheduledDate = scheduledDate
        self.avatarId = avatarId
        self.repeatMode = repeatMode
    }
    
    var isValid: Bool {
        return !content.isEmpty && scheduledDate > Date() && !avatarId.isEmpty
    }
    
    enum RepeatMode: String, Codable, CaseIterable {
        case none = "none"
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
        case yearly = "yearly"
        
        var displayName: String {
            switch self {
            case .none: return "Aucune"
            case .daily: return "Quotidien"
            case .weekly: return "Hebdomadaire"
            case .monthly: return "Mensuel"
            case .yearly: return "Annuel"
            }
        }
    }
}

// MARK: - Avatar animé
struct AnimatedAvatar: Identifiable, Codable {
    var id: UUID
    var name: String
    var lottieFileName: String
    var soundFile: String?
    var category: Category
    var isPremium: Bool = false
    
    init(id: UUID = UUID(), name: String, lottieFileName: String, soundFile: String? = nil, category: Category, isPremium: Bool = false) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lottieFileName = lottieFileName
        self.soundFile = soundFile
        self.category = category
        self.isPremium = isPremium
    }
    
    var isValid: Bool {
        return !name.isEmpty && !lottieFileName.isEmpty
    }
    
    enum Category: String, Codable, CaseIterable {
        case animals = "animals"
        case funny = "funny"
        case romantic = "romantic"
        case birthday = "birthday"
        case holiday = "holiday"
        
        var displayName: String {
            switch self {
            case .animals: return "Animaux"
            case .funny: return "Drôle"
            case .romantic: return "Romantique"
            case .birthday: return "Anniversaire"
            case .holiday: return "Vacances"
            }
        }
    }
}

// MARK: - Message reçu
struct ReceivedMessage: Identifiable, Codable {
    var id: UUID
    var fromContactId: UUID
    var content: String
    var avatarId: String
    var receivedAt: Date = Date()
    var isRead: Bool = false
    
    init(id: UUID = UUID(), fromContactId: UUID, content: String, avatarId: String) {
        self.id = id
        self.fromContactId = fromContactId
        self.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.avatarId = avatarId
    }
    
    var isValid: Bool {
        return !content.isEmpty && !avatarId.isEmpty
    }
}

// MARK: - Paramètres utilisateur
struct UserSettings: Codable {
    var enableSound: Bool = true
    var enableVibration: Bool = true
    var discretMode: Bool = false
    var notificationHour: DateComponents?
    var theme: AppTheme = .auto
    
    enum AppTheme: String, Codable, CaseIterable {
        case light = "light"
        case dark = "dark"
        case auto = "auto"
        
        var displayName: String {
            switch self {
            case .light: return "Clair"
            case .dark: return "Sombre"
            case .auto: return "Automatique"
            }
        }
    }
}

// MARK: - Extensions pour les previews
extension Contact {
    static let preview = Contact(
        name: "Alice",
        phone: "+33612345678",
        avatarId: "cat_happy",
        isValidated: true
    )
}

extension ScheduledMessage {
    static let preview = ScheduledMessage(
        contactId: UUID(),
        content: "Joyeux anniversaire ! 🎉",
        scheduledDate: Date().addingTimeInterval(3600),
        avatarId: "birthday_cake"
    )
}

extension AnimatedAvatar {
    static let preview = AnimatedAvatar(
        name: "Chat joyeux",
        lottieFileName: "cat_happy",
        soundFile: "meow.mp3",
        category: .animals,
        isPremium: false
    )
    
    static let defaultAvatars: [AnimatedAvatar] = [
        AnimatedAvatar(name: "Chat joyeux", lottieFileName: "cat_happy", soundFile: "meow.mp3", category: .animals),
        AnimatedAvatar(name: "Chien mignon", lottieFileName: "dog_cute", soundFile: "woof.mp3", category: .animals),
        AnimatedAvatar(name: "Coeur battant", lottieFileName: "heart_beat", category: .romantic),
        AnimatedAvatar(name: "Gâteau festif", lottieFileName: "birthday_cake", soundFile: "party.mp3", category: .birthday),
        AnimatedAvatar(name: "Clown rigolo", lottieFileName: "clown_fun", soundFile: "laugh.mp3", category: .funny)
    ]
}