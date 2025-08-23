# KnockAvatar 👋

Application iOS innovante pour envoyer des messages avec des avatars animés personnalisés.

## 🎯 Fonctionnalités

- **Messages animés** : Envoyez des messages accompagnés d'animations d'avatar expressives
- **Notifications push** : Recevez des alertes avec animations intégrées
- **Messages programmés** : Planifiez l'envoi de messages à l'avance
- **Gestion des contacts** : Import depuis le carnet d'adresses iOS
- **Mode répétition** : Configurez des messages récurrents (quotidien, hebdomadaire, mensuel)
- **Deep links** : Navigation directe vers les sections de l'app

## 📱 Configuration requise

- iOS 15.0 ou supérieur
- iPhone, iPad ou iPod touch
- Xcode 14+ pour le développement
- macOS pour la compilation

## 🚀 Installation

### Prérequis
- Xcode installé sur votre Mac
- Compte Apple Developer (gratuit ou payant)
- CocoaPods ou Swift Package Manager

### Étapes

1. Clonez le repository :
```bash
git clone https://github.com/tyler2797/app-ios-maman-.git
cd app-ios-maman-
```

2. Ouvrez le projet dans Xcode :
```bash
open KnockAvatar.xcodeproj
```

3. Installez les dépendances (Lottie) via Swift Package Manager dans Xcode

4. Configurez votre équipe de développement dans les paramètres de signature

5. Compilez et lancez sur simulateur ou appareil réel

## 🏗️ Architecture

```
KnockAvatar/
├── Models/
│   └── DataModels.swift          # Modèles de données
├── Services/
│   ├── DataStore.swift           # Gestion des données locales
│   ├── DeepLinkManager.swift     # Gestion des deep links
│   └── NotificationManager.swift # Gestion des notifications
├── Views/
│   ├── ContentView.swift         # Vue principale
│   ├── AvatarAnimationOverlay.swift
│   ├── ComposeMessageView.swift
│   ├── MessagesListView.swift
│   ├── SettingsView.swift
│   └── AddContactView.swift
└── NotificationServiceExtension/
    └── NotificationService.swift  # Extension pour notifications riches
```

## 🛠️ Technologies utilisées

- **SwiftUI** : Interface utilisateur moderne et déclarative
- **Combine** : Programmation réactive
- **CoreData** : Stockage local des données
- **UserNotifications** : Notifications push et locales
- **Lottie** : Animations vectorielles fluides
- **Contacts Framework** : Accès au carnet d'adresses

## 📖 Documentation

Consultez le fichier [SETUP_EXPORT_IPA.md](SETUP_EXPORT_IPA.md) pour un guide complet sur :
- La configuration du projet Xcode
- La signature de l'application
- L'export en fichier .ipa
- Le déploiement sur appareil

## 🧪 Mode Test

L'application inclut un mode simulateur pour tester sans notifications push réelles :
- Bouton de simulation de réception de messages
- Tests des animations d'avatar
- Debug de l'interface utilisateur

## 🔒 Permissions requises

- **Notifications** : Pour recevoir les messages
- **Contacts** : Pour importer les contacts (optionnel)
- **Réseau** : Pour la synchronisation future avec un serveur

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commit vos changements
4. Push vers la branche
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## 👨‍💻 Auteur

Développé avec ❤️ pour faciliter la communication avec des messages animés expressifs.

## 🚧 Roadmap

- [ ] Backend Firebase pour synchronisation
- [ ] Plus d'animations Lottie
- [ ] Thèmes personnalisables
- [ ] Support iPad optimisé
- [ ] Widget iOS
- [ ] Apple Watch companion app
- [ ] Chiffrement bout-en-bout
- [ ] Partage de médias (photos/vidéos)

## 📞 Support

Pour toute question ou problème, ouvrez une issue sur GitHub.