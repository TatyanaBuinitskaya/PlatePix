//
//  PlatePixApp.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import CoreSpotlight
import RevenueCat
import SwiftUI
import WidgetKit

/// The main entry point of the PlatePix application, responsible for initializing the app's environment.
@main
struct PlatePixApp: App {
    /// Adapts `AppDelegate` for use with SwiftUI's application lifecycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openURL) var openURL

    var body: some Scene {
        WindowGroup {
            AppView()
                .onOpenURL { url in
                    if url.scheme == "platepix", url.host == "store" {
                        NotificationCenter.default.post(name: .openStoreView, object: nil)
                    }
                }
               
        }
    }

//    init() {
//        Purchases.logLevel = .debug
//        Purchases.configure(withAPIKey: "appl_XivMTqpJYjMYwMHtKPZXIipMuMP")
//    }
}

extension Notification.Name {
    static let openStoreView = Notification.Name("OpenStoreView")
}
