//
//  SceneDelegate.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 12.02.2025.
//

import SwiftUI

/// The `SceneDelegate` class manages scene-level events, including handling quick actions and scene connections.
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    /// Handles quick actions (Home Screen shortcuts) when the app is already running.
        /// - Parameters:
        ///   - windowScene: The scene requesting the action.
        ///   - shortcutItem: The shortcut item that was triggered.
        ///   - completionHandler: A closure to be called with the result of the action.
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        // Convert the shortcut item's type to a URL and attempt to open it.
        guard let url = URL(string: shortcutItem.type) else {
            // If the URL is invalid, complete with a failure.
            completionHandler(false)
            return
        }
        // Open the URL and pass the result to the completion handler.
        windowScene.open(url, options: nil, completionHandler: completionHandler)
    }

    /// Called when the scene is being set up.
        /// Handles quick actions launched from the Home Screen while the app is not running.
        /// - Parameters:
        ///   - scene: The scene being connected.
        ///   - session: The session associated with the scene.
        ///   - connectionOptions: Additional options for configuring the scene.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Check if the scene was launched from a Home Screen quick action.
        if let shortcutItem = connectionOptions.shortcutItem {
            // Convert the shortcut item's type to a URL and attempt to open it.
            if let url = URL(string: shortcutItem.type) {
                scene.open(url, options: nil)
            }
        }
    }
}
