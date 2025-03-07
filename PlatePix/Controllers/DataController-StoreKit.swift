//
//  DataController-StoreKit.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 11.02.2025.
//

import Foundation
import StoreKit

extension DataController {
    /// The product ID for the premium unlock feature.
    /// This is used to identify the purchase in the App Store.
    static let unlockPremiumProductID = "com.TatianaBuinitskaia.PlatePix.premiumUnlock"
    /// A computed property that checks if the full version has been unlocked.
    /// The value is stored in `UserDefaults` for persistence.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }

        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    /// Monitors transaction updates for verifying past and future purchases.
    /// This function listens for any previously completed transactions and automatically unlocks features if the purchase is valid.
    func monitorTransactions() async {
        // Check for previous purchases.
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement {
                await finalize(transaction) // Process verified transactions.
            }
        }

        // Watch for future transactions coming in.
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }

    /// Initiates the purchase process for a given `Product`.
    /// - Parameter product: The in-app purchase product the user is trying to buy.
    /// - Throws: An error if the purchase fails.
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        // If the purchase is successful, validate the transaction and finalize it.
        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }

    /// Finalizes a purchase by verifying and marking the transaction as complete.
    /// - Parameter transaction: The transaction received from the App Store.
    /// - This function checks if the purchase is for the premium unlock and updates the `fullVersionUnlocked` flag accordingly.
    @MainActor
    func finalize(_ transaction: Transaction) async {
        if transaction.productID == Self.unlockPremiumProductID {
            objectWillChange.send() // Notify the UI that the state has changed.
            // Unlock the full version if the transaction has not been revoked.
            fullVersionUnlocked = transaction.revocationDate == nil
            // Mark the transaction as finished in the App Store to prevent reprocessing.
            await transaction.finish()
        }
    }

    /// Loads the available in-app products for premium unlock, ensuring products are loaded only once.
    /// This function fetches the unlock premium products if they haven't been loaded already. It adds a slight delay
    /// before loading to allow smooth UI transitions.
    /// - Throws: Propagates errors if loading products fails.
    @MainActor
    func loadProducts() async throws {
        // don't load products more than once
        guard products.isEmpty else { return }

        try await Task.sleep(for: .seconds(0.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }
}
