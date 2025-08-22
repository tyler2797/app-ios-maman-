// AvatarAnimationOverlay.swift
// Overlay d'animation Lottie lors de la réception d'un message

import SwiftUI
import Lottie

struct AvatarAnimationOverlay: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var dataStore: DataStore
    @State private var showMessage = false
    @State private var animationProgress: CGFloat = 0
    @State private var tapCount = 0
    
    var body: some View {
        ZStack {
            // Fond semi-transparent
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap en dehors pour fermer
                    dismissOverlay()
                }
            
            VStack(spacing: 30) {
                // Animation Lottie
                if let avatarAnimation = notificationManager.currentAvatarAnimation {
                    LottieAnimationView(
                        animationName: avatarAnimation,
                        loopMode: .playOnce,
                        animationProgress: $animationProgress
                    )
                    .frame(width: 200, height: 200)
                    .onTapGesture {
                        handleAvatarTap()
                    }
                    .scaleEffect(1 + CGFloat(tapCount) * 0.1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: tapCount)
                } else {
                    // Fallback animation native
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        .symbolEffect(.pulse)
                }
                
                // Message après animation
                if showMessage, let message = notificationManager.pendingMessage {
                    MessageBubble(message: message)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Instructions
                if !showMessage {
                    Text("Tape l'avatar !")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
            .padding()
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Vibration initiale
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Démarrer l'animation après un court délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2)) {
                animationProgress = 1
            }
        }
    }
    
    private func handleAvatarTap() {
        tapCount += 1
        
        // Vibration à chaque tap
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Afficher le message après 3 taps
        if tapCount >= 3 && !showMessage {
            withAnimation(.spring()) {
                showMessage = true
            }
            
            // Marquer comme lu
            if let message = notificationManager.pendingMessage {
                dataStore.markMessageAsRead(message.id)
            }
            
            // Auto-dismiss après 3 secondes
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismissOverlay()
            }
        }
    }
    
    private func dismissOverlay() {
        withAnimation(.easeOut(duration: 0.3)) {
            notificationManager.showAnimationOverlay = false
            notificationManager.pendingMessage = nil
            notificationManager.currentAvatarAnimation = nil
        }
    }
}

// MARK: - Bulle de message
struct MessageBubble: View {
    let message: ReceivedMessage
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let contact = dataStore.getContact(by: message.fromContactId) {
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text(String(contact.name.prefix(1)))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        )
                    
                    Text(contact.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            
            Text(message.content)
                .font(.body)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(15)
            
            Text(message.receivedAt, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - Wrapper Lottie
struct LottieAnimationView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    @Binding var animationProgress: CGFloat
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        // Créer la vue Lottie
        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        
        // Auto-layout
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Démarrer l'animation
        animationView.play()
        
        context.coordinator.animationView = animationView
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.animationView?.currentProgress = animationProgress
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var animationView: LottieAnimationView?
    }
}