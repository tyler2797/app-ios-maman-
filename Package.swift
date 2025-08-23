// swift-tools-version:5.9
// Package.swift - Configuration des dépendances Swift Package Manager

import PackageDescription

let package = Package(
    name: "KnockAvatar",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "KnockAvatar",
            targets: ["KnockAvatar"]
        )
    ],
    dependencies: [
        // Lottie pour les animations vectorielles fluides
        .package(
            url: "https://github.com/airbnb/lottie-ios.git", 
            from: "4.3.0"
        )
        
        // FUTURE: Firebase pour le backend cloud
        // Décommentez quand prêt pour la synchronisation cloud :
        // .package(
        //     url: "https://github.com/firebase/firebase-ios-sdk.git", 
        //     from: "10.18.0"
        // )
    ],
    targets: [
        .target(
            name: "KnockAvatar",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
                
                // FUTURE: Notifications push Firebase
                // .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "KnockAvatarTests",
            dependencies: ["KnockAvatar"]
        )
    ],
    swiftLanguageVersions: [.v5]
)