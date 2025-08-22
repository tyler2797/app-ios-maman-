// DeepLinkManager.swift
// Gestionnaire de deep linking pour navigation directe

import Foundation
import SwiftUI

class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var activeTab: Tab = .home
    @Published var selectedMessageId: String?
    @Published var showMessageDetail: Bool = false
    @Published var navigateToComposer: Bool = false
    
    enum Tab: String {
        case home
        case messages
        case compose
        case settings
    }
    
    private init() {}
    
    // MARK: - Gestion des URLs
    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        // Format attendu: knockavatar://message/{messageId}
        // ou knockavatar://compose/{contactId}
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        guard !pathComponents.isEmpty else { return }
        
        switch pathComponents[0] {
        case "message":
            if pathComponents.count > 1 {
                handleMessageDeepLink(messageId: pathComponents[1])
            }
            
        case "compose":
            if pathComponents.count > 1 {
                handleComposeDeepLink(contactId: pathComponents[1])
            }
            
        case "settings":
            activeTab = .settings
            
        default:
            break
        }
    }
    
    // MARK: - Navigation vers un message
    private func handleMessageDeepLink(messageId: String) {
        DispatchQueue.main.async {
            self.selectedMessageId = messageId
            self.activeTab = .messages
            self.showMessageDetail = true
            
            // Déclencher l'animation si le message est nouveau
            if let message = DataStore.shared.getReceivedMessage(by: messageId) {
                NotificationManager.shared.currentAvatarAnimation = message.avatarId
                NotificationManager.shared.showAnimationOverlay = true
                NotificationManager.shared.pendingMessage = message
            }
        }
    }
    
    // MARK: - Navigation vers composition
    private func handleComposeDeepLink(contactId: String) {
        DispatchQueue.main.async {
            self.activeTab = .compose
            self.navigateToComposer = true
            // Préselectionner le contact dans la vue composer
            if let uuid = UUID(uuidString: contactId) {
                DataStore.shared.selectedContactId = uuid
            }
        }
    }
    
    // MARK: - Reset navigation
    func resetNavigation() {
        selectedMessageId = nil
        showMessageDetail = false
        navigateToComposer = false
    }
}