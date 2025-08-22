# 📱 Guide complet : Signature et Export .ipa pour KnockAvatar

## 🔧 Prérequis

1. **Xcode** (version 14 ou supérieure)
2. **Compte Apple** (gratuit ou payant)
3. **iPhone** pour tester (ou simulateur iOS)

## 📋 Étape 1 : Créer le projet Xcode

1. Ouvrir **Xcode**
2. **File → New → Project**
3. Choisir **iOS → App**
4. Configuration :
   - Product Name: `KnockAvatar`
   - Team: Sélectionner votre Apple ID
   - Organization Identifier: `com.votredomaine` (ou `com.yourname`)
   - Bundle Identifier: `com.votredomaine.KnockAvatar`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Use Core Data: ✅
   - Include Tests: ✅

## 📦 Étape 2 : Ajouter les dépendances

### Via Swift Package Manager dans Xcode :

1. **File → Add Package Dependencies**
2. Ajouter Lottie :
   - URL: `https://github.com/airbnb/lottie-ios`
   - Version: `Up to Next Major` → `4.3.0`
3. Cliquer **Add Package**

## 🎯 Étape 3 : Ajouter les fichiers du projet

1. **Supprimer** les fichiers par défaut :
   - ContentView.swift
   - App.swift

2. **Glisser-déposer** tous les fichiers Swift créés dans le projet :
   ```
   KnockAvatarApp.swift
   Models/
     └── DataModels.swift
   Services/
     ├── NotificationManager.swift
     ├── DeepLinkManager.swift
     └── DataStore.swift
   Views/
     ├── ContentView.swift
     ├── AvatarAnimationOverlay.swift
     ├── ComposeMessageView.swift
     ├── MessagesListView.swift
     ├── SettingsView.swift
     └── AddContactView.swift
   ```

## 🔔 Étape 4 : Ajouter la Notification Service Extension

1. **File → New → Target**
2. Choisir **iOS → Notification Service Extension**
3. Configuration :
   - Product Name: `NotificationService`
   - Team: Votre Apple ID
   - Language: Swift
4. Activer l'extension quand demandé
5. Remplacer le code par celui fourni dans `NotificationService.swift`

## ⚙️ Étape 5 : Configuration des Capabilities

### Dans la target principale (KnockAvatar) :

1. Sélectionner le projet dans le navigateur
2. Target **KnockAvatar** → **Signing & Capabilities**
3. Cliquer **+ Capability** et ajouter :
   - **Push Notifications**
   - **Background Modes** :
     - ✅ Remote notifications
     - ✅ Background fetch

### Pour la Notification Extension :

1. Target **NotificationService** → **Signing & Capabilities**
2. Vérifier que le signing est configuré

## 🔑 Étape 6 : Signature avec compte Apple gratuit

### Configuration du signing :

1. **Target KnockAvatar → Signing & Capabilities**
2. **Team** : Sélectionner votre Apple ID
3. Si pas de team :
   - Cliquer **Add an Account**
   - Se connecter avec votre Apple ID
   - Xcode créera automatiquement un certificat de développement

### Limitations compte gratuit :
- ✅ Test sur votre iPhone personnel (jusqu'à 3 appareils)
- ✅ Validité 7 jours (re-signer après)
- ❌ Pas de distribution App Store
- ❌ Pas de notifications push réelles (seulement locales)

## 📲 Étape 7 : Test sur iPhone réel

1. **Connecter** votre iPhone via USB
2. **Déverrouiller** l'iPhone et faire confiance à l'ordinateur
3. Dans Xcode, sélectionner votre iPhone dans la barre d'outils
4. **Product → Run** (ou Cmd+R)

### Première installation :
1. Sur iPhone : **Réglages → Général → VPN et gestion d'appareils**
2. Sous **Profils de développeur**, sélectionner votre Apple ID
3. Taper **Faire confiance**

## 📤 Étape 8 : Export .ipa

### A. Archive de l'app :

1. Sélectionner **Generic iOS Device** ou votre iPhone dans le scheme
2. **Product → Archive**
3. Attendre la compilation (2-5 minutes)

### B. Export depuis Organizer :

1. **Window → Organizer** s'ouvre automatiquement
2. Sélectionner votre archive
3. Cliquer **Distribute App**
4. Choisir :
   - **Development** (pour tests internes)
   - Ou **Ad Hoc** (si vous avez un compte payant)
5. Options d'export :
   - App Thinning: **None**
   - ✅ Include manifest for OTA
   - ✅ Rebuild from Bitcode
6. **Next** → **Export**
7. Choisir le dossier de destination

### C. Fichiers générés :

```
KnockAvatar_Export/
├── KnockAvatar.ipa          # Le fichier à installer
├── manifest.plist            # Pour installation OTA
├── DistributionSummary.plist # Résumé de l'export
└── ExportOptions.plist      # Options utilisées
```

## 🚀 Étape 9 : Installation du .ipa

### Option 1 : Via Xcode (recommandé)

1. **Window → Devices and Simulators**
2. Sélectionner votre iPhone
3. Glisser le `.ipa` dans la section **Installed Apps**

### Option 2 : Via Apple Configurator 2

1. Télécharger depuis Mac App Store
2. Connecter l'iPhone
3. Glisser le `.ipa` sur l'appareil

### Option 3 : Via services tiers (TestFlight alternative)

- **Diawi** : https://www.diawi.com (gratuit, limite 10 downloads)
- **Installr** : https://www.installr.com
- **HockeyApp** : (maintenant App Center)

## 🐛 Étape 10 : Debug et troubleshooting

### Erreurs courantes :

1. **"Failed to verify code signature"**
   - Solution : Re-signer avec un profil valide
   - Vérifier la date d'expiration (7 jours compte gratuit)

2. **"Could not launch app"**
   - Solution : Faire confiance au développeur dans Réglages

3. **Push notifications ne fonctionnent pas**
   - Normal avec compte gratuit
   - Utiliser les notifications locales pour tester

### Mode simulateur pour tests :

Le code inclut un mode simulateur (`#if targetEnvironment(simulator)`) qui permet :
- Simuler la réception de messages
- Tester les animations sans push réels
- Débugger l'interface

## 📝 Configuration serveur (pour production)

Pour un déploiement complet, vous aurez besoin :

1. **Compte Apple Developer payant** (99$/an)
2. **Certificat APNs** pour push notifications
3. **Serveur backend** (Firebase, Node.js, etc.) avec :
   ```javascript
   // Exemple Firebase Cloud Functions
   exports.sendScheduledMessage = functions.pubsub
     .schedule('every minute')
     .onRun(async (context) => {
       // Vérifier les messages à envoyer
       // Envoyer via APNs
     });
   ```

## 🎨 Ajouter les animations Lottie

1. Télécharger des animations depuis https://lottiefiles.com
2. Exporter en `.json`
3. Glisser dans le projet Xcode
4. Référencer dans le code :
   ```swift
   LottieAnimationView(name: "cat_happy")
   ```

## ✅ Checklist finale

- [ ] Projet créé dans Xcode
- [ ] Dépendances ajoutées (Lottie)
- [ ] Fichiers Swift intégrés
- [ ] Notification Extension configurée
- [ ] Capabilities activées
- [ ] Signing configuré
- [ ] Test sur iPhone réel
- [ ] Archive créée
- [ ] .ipa exporté
- [ ] App installée et fonctionnelle

## 📚 Ressources

- [Documentation Apple - Notifications](https://developer.apple.com/documentation/usernotifications)
- [Lottie iOS](https://github.com/airbnb/lottie-ios)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

---

**Note**: Ce guide couvre le MVP. Pour la production, implémentez :
- Authentification utilisateurs
- Base de données cloud
- Serveur APNs
- Analytics et crash reporting
- Tests unitaires et UI