//
//  SupportEmail.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 18.02.2025.
//

import Foundation
import UIKit
import SwiftUICore

/// A structure that represents an email for user support.
/// It includes the recipient's email address, subject, message header, and optional data attachments.
struct SupportEmail {
    let toAddress: String // The recipient email address for support.
    let subject: String // The subject line of the email.
    let messageHeader: String // The main content header, customizable for different support cases.
    var data: Data? // Optional data attachment (not currently used in the email body).

    /// The email body, automatically populated with app and device details.
       /// Includes:
       /// - App name, version, and build number
       /// - iOS version
       /// - Device model
       /// - A custom message header
    var body: String {"""
        Application Name: \(Bundle.main.displayName)
        iOS: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.modelName)
        Appp Version: \(Bundle.main.appVersion)
        App Build: \(Bundle.main.appBuild)
        \(messageHeader)
    --------------------------------------
    """
    }

    /// Attempts to open the default email app with a pre-filled support email.
    /// - Parameter openURL: A SwiftUI `OpenURLAction` used to open mail clients.
    func send(openURL: OpenURLAction) {
        // Constructs the email URL with subject and body encoded to be URL-safe.
        let urlString = "mailto:\(toAddress)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        // Ensures the URL is valid before attempting to open it.
        guard let url = URL(string: urlString) else { return }
        // Tries to open the email client.
        openURL(url) { accepted in
            if !accepted {
                // If the device does not support email (e.g., no mail app installed), print the message to the console.
                print("""
                This device does not support email
                \(body)
                """
                )
            }
        }
    }
}
