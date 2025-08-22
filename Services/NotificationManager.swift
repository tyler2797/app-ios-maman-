// NotificationManager.swift
// Gestionnaire des notifications push et locales

import Foundation
import SwiftUI
import UserNotifications
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var deviceToken: String?
    @Published var pendingMessage: ReceivedMessage?
    @Published var showAnimationOverlay: Bool = false
    @Published var currentAvatarAnimation: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        setupNotifications()
    }
    
    // MARK: - Configuration initiale
    private func setupNotifications() {
        // Observer les changements de statut d'autorisation
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
                self.checkNotificationStatus()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Vérification du statut
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    print("✅ Notifications autorisées")
                case .denied:
                    print("❌ Notifications refusées")
                case .notDetermined:
                    self.requestAuthorization()
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Demande d'autorisation
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // MARK: - Gestion notification au premier plan
    func handleForegroundNotification(userInfo: [AnyHashable: Any]) {
        guard let messageData = extractMessageData(from: userInfo) else { return }
        
        // Mode discret = pas d'animation
        if UserDefaults.standard.bool(forKey: "discretMode") {
            return
        }
        
        // Afficher l'animation overlay
        DispatchQueue.main.async {
            self.currentAvatarAnimation = messageData.avatarId
            self.pendingMessage = messageData.message
            self.showAnimationOverlay = true
            
            // Vibration et son
            self.playNotificationFeedback()
        }
    }
    
    // MARK: - Gestion tap sur notification
    func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        guard let messageData = extractMessageData(from: userInfo) else { return }
        
        DispatchQueue.main.async {
            // Deep link vers le message
            self.pendingMessage = messageData.message
            self.currentAvatarAnimation = messageData.avatarId
            self.showAnimationOverlay = true
            
            // Vibration
            self.playNotificationFeedback()
        }
    }
    
    // MARK: - Extraction des données
    private func extractMessageData(from userInfo: [AnyHashable: Any]) -> (message: ReceivedMessage, avatarId: String)? {
        guard let messageId = userInfo["messageId"] as? String,
              let content = userInfo["content"] as? String,
              let avatarId = userInfo["avatarId"] as? String,
              let contactIdString = userInfo["contactId"] as? String,
              let contactId = UUID(uuidString: contactIdString) else {
            return nil
        }
        
        let message = ReceivedMessage(
            fromContactId: contactId,
            content: content,
            avatarId: avatarId
        )
        
        return (message, avatarId)
    }
    
    // MARK: - Programmation notification locale (pour tests)
    func scheduleLocalNotification(message: ScheduledMessage, contact: Contact) {
        let content = UNMutableNotificationContent()
        content.title = "Toc toc, tu as un message"
        content.subtitle = "De \(contact.name)"
        content.body = message.content
        content.sound = .default
        content.badge = 1
        
        // Données pour le deep link
        content.userInfo = [
            "messageId": message.id.uuidString,
            "contactId": contact.id.uuidString,
            "content": message.content,
            "avatarId": message.avatarId
        ]
        
        // Trigger basé sur la date
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: message.scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: message.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erreur programmation notification: \(error)")
            } else {
                print("✅ Notification programmée pour \(message.scheduledDate)")
            }
        }
    }
    
    // MARK: - Feedback haptique et son
    private func playNotificationFeedback() {
        // Vibration
        if UserDefaults.standard.bool(forKey: "enableVibration") != false {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        
        // Son custom si disponible
        // AudioServicesPlaySystemSound(1007) // Son système
    }
    
    // MARK: - Annuler une notification
    func cancelNotification(messageId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [messageId])
    }
    
    // MARK: - Badge
    func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}