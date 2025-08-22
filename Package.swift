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
        // Lottie pour les animations
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.0"),
        
        // Firebase pour le backend (optionnel pour MVP)
        // .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "KnockAvatar",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
                // .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ]
        )
    ]
)