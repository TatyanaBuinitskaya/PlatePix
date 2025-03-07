//
//  AppDelegate.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 12.02.2025.
//

import SwiftUI

/// The `AppDelegate` class manages application-level events.
/// It is responsible for configuring new scene sessions.
class AppDelegate: NSObject, UIApplicationDelegate {
    /// Called when a new scene session is being created.
      /// This method allows specifying the configuration for the new scene.
      /// - Parameters:
      ///   - application: The singleton app object.
      ///   - connectingSceneSession: The scene session being created.
      ///   - options: Additional options for configuring the scene.
      /// - Returns: A `UISceneConfiguration` to create the new scene.
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Create a default scene configuration with the same role as the connecting session.
        let sceneConfiguration = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        // Specify the delegate class for managing scene-level events.
        sceneConfiguration.delegateClass = SceneDelegate.self
        // Return the configured scene.
        return sceneConfiguration
    }
}
