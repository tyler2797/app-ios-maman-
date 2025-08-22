// DataModels.swift
// Modèles de données pour KnockAvatar

import Foundation
import SwiftUI

// MARK: - Contact
struct Contact: Identifiable, Codable {
    let id = UUID()
    var name: String
    var phone: String
    var avatarId: String
    var isValidated: Bool = false // Contact mutuellement validé
    var createdAt: Date = Date()
}

// MARK: - Message programmé
struct ScheduledMessage: Identifiable, Codable {
    let id = UUID()
    var contactId: UUID
    var content: String
    var scheduledDate: Date
    var avatarId: String
    var repeatMode: RepeatMode = .none
    var isDelivered: Bool = false
    var createdAt: Date = Date()
    
    enum RepeatMode: String, Codable, CaseIterable {
        case none = "Aucune"
        case daily = "Quotidien"
        case weekly = "Hebdomadaire"
        case monthly = "Mensuel"
        case yearly = "Annuel"
    }
}

// MARK: - Avatar animé
struct AnimatedAvatar: Identifiable, Codable {
    let id = UUID()
    var name: String
    var lottieFileName: String
    var soundFile: String?
    var category: Category
    var isPremium: Bool = false
    
    enum Category: String, Codable, CaseIterable {
        case animals = "Animaux"
        case funny = "Drôle"
        case romantic = "Romantique"
        case birthday = "Anniversaire"
        case holiday = "Vacances"
    }
}

// MARK: - Message reçu
struct ReceivedMessage: Identifiable, Codable {
    let id = UUID()
    var fromContactId: UUID
    var content: String
    var avatarId: String
    var receivedAt: Date = Date()
    var isRead: Bool = false
}

// MARK: - Paramètres utilisateur
struct UserSettings: Codable {
    var enableSound: Bool = true
    var enableVibration: Bool = true
    var discretMode: Bool = false
    var notificationHour: DateComponents?
    var theme: AppTheme = .auto
    
    enum AppTheme: String, Codable, CaseIterable {
        case light = "Clair"
        case dark = "Sombre"
        case auto = "Automatique"
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