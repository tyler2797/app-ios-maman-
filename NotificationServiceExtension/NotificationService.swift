// NotificationService.swift
// Notification Service Extension pour enrichir les notifications push

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        // Extraire les données du payload
        let userInfo = request.content.userInfo
        
        // Modifier le contenu de la notification
        if let avatarId = userInfo["avatarId"] as? String {
            // Ajouter l'image de l'avatar
            attachAvatarImage(avatarId: avatarId, to: bestAttemptContent)
        }
        
        // Ajouter des actions
        addNotificationActions(to: bestAttemptContent)
        
        // Personnaliser le son si disponible
        if let soundName = userInfo["soundFile"] as? String {
            bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
        }
        
        contentHandler(bestAttemptContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    // MARK: - Attacher l'image de l'avatar
    private func attachAvatarImage(avatarId: String, to content: UNMutableNotificationContent) {
        // Chercher l'image dans le bundle
        guard let imageURL = Bundle.main.url(forResource: avatarId, withExtension: "png") else {
            // Utiliser une image par défaut si non trouvée
            attachDefaultImage(to: content)
            return
        }
        
        do {
            let attachment = try UNNotificationAttachment(
                identifier: "avatar",
                url: imageURL,
                options: [
                    UNNotificationAttachmentOptionsTypeHintKey: "public.png",
                    UNNotificationAttachmentOptionsThumbnailHiddenKey: false
                ]
            )
            content.attachments = [attachment]
        } catch {
            print("❌ Erreur attachement image: \(error)")
            attachDefaultImage(to: content)
        }
    }
    
    // MARK: - Image par défaut
    private func attachDefaultImage(to content: UNMutableNotificationContent) {
        // Créer une image par défaut programmatiquement
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Dessiner un cercle avec une icône
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.systemBlue.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        // Ajouter un emoji ou symbole
        let text = "👋" as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 50),
            .foregroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Sauvegarder temporairement et attacher
        if let image = image,
           let data = image.pngData() {
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("default_avatar.png")
            
            do {
                try data.write(to: tempURL)
                let attachment = try UNNotificationAttachment(
                    identifier: "default",
                    url: tempURL,
                    options: [
                        UNNotificationAttachmentOptionsTypeHintKey: "public.png",
                        UNNotificationAttachmentOptionsThumbnailHiddenKey: false
                    ]
                )
                content.attachments = [attachment]
            } catch {
                print("❌ Erreur création image par défaut: \(error)")
            }
        }
    }
    
    // MARK: - Actions de notification
    private func addNotificationActions(to content: UNMutableNotificationContent) {
        // Créer les actions
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "Voir le message",
            options: [.foreground]
        )
        
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_ACTION",
            title: "Répondre",
            options: [],
            textInputButtonTitle: "Envoyer",
            textInputPlaceholder: "Écris ta réponse..."
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Plus tard",
            options: []
        )
        
        // Créer la catégorie
        let category = UNNotificationCategory(
            identifier: "MESSAGE_CATEGORY",
            actions: [viewAction, replyAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Enregistrer la catégorie
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // Assigner la catégorie à la notification
        content.categoryIdentifier = "MESSAGE_CATEGORY"
    }
}