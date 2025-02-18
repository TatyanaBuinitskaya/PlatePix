//
//  StoreView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 11.02.2025.
//

import StoreKit
import SwiftUI

/// A view that displays the store where users can purchase the premium version of the app.
struct StoreView: View {
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// Enum representing the loading state of data.
    enum LoadState {
        case loading, loaded, error
    }
    /// Access to the shared `DataController` instance.
    @EnvironmentObject var dataController: DataController
    /// Environment property to allow dismissing the store view.
    @Environment(\.dismiss) var dismiss
    /// The current state of the data loading process. Initialized to `.loading`.
    @State private var loadState = LoadState.loading
    /// A state variable that tracks whether a purchase error has occurred.
    @State private var showingPurchaseError = false


    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Display the unlock image and title promoting the upgrade
                VStack {
                    Image(decorative: "unlock")
                        .resizable()
                        .scaledToFit()

                    Text("Upgrade Today!")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Text("Get the most out of the app")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(colorManager.selectedColor.color.gradient)

                // Scrollable content section
                ScrollView {
                    VStack {
                        // Display loading state
                        switch loadState {
                        case .loading:
                            Text("Fetching offers…")
                                .font(.title2.bold())
                                .padding(.top, 50)
                            ProgressView()
                                .controlSize(.large)
                        // Display products when loaded
                        case .loaded:
                            ForEach(dataController.products) { product in
                                Button {
                                    purchase(product)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(product.displayName)
                                                .font(.title2.bold())
                                            Text(product.description)
                                        }

                                        Spacer()

                                        Text(product.displayPrice)
                                            .font(.title)
                                            .fontDesign(.rounded)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(.gray.opacity(0.2), in: .rect(cornerRadius: 20))
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }
                        // Display error message if products couldn't load
                        case .error:
                            Text("Sorry, there was an error loading our store.")
                                .padding(.top, 50)
                            Button("Try Again") {
                                Task {
                                    await load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(20)
                }
                // Button for restoring previous purchases
                Button("Restore Purchases", action: restore)
                // Button to close the view
                Button("Cancel") {
                    dismiss()
                }
                .padding(.top, 20)
            }
        }
        // Alert for when in-app purchases are disabled
        .alert("In-app purchases are disabled", isPresented: $showingPurchaseError) {
        } message: {
            Text("""
            You can't purchase the premium unlock because in-app purchases are disabled on this device.

            Please ask whomever manages your device for assistance.
            """)
        }
        // Listens for changes in the premium unlock status and dismisses the store if the purchase is completed.
        .onChange(of: dataController.fullVersionUnlocked) {
            checkForPurchase()
        }
        // Loads available products when the view appears.
        .task {
            await load()
        }
    }

    /// Checks if the user has unlocked the full version and dismisses the store if so.
    func checkForPurchase() {
        if dataController.fullVersionUnlocked {
            dismiss()
            if dataController.newPlate() {
                dataController.isNewPlateCreated = true // Trigger navigation
                   }
        }
    }

    /// Initiates the purchase of the given product.
    /// - Parameter product: The `Product` to be purchased.
    func purchase(_ product: Product) {
        guard AppStore.canMakePayments else {
            showingPurchaseError.toggle()
            return
        }
        Task { @MainActor in
            try await dataController.purchase(product)
        }
    }

    /// Asynchronously loads the available products from the `dataController` and updates the load state accordingly.
    func load() async {
        loadState = .loading

        do {
            // Attempts to load the products using the dataController.
            try await dataController.loadProducts()
            // Checks if any products were loaded, and updates the load state accordingly.
            if dataController.products.isEmpty {
                loadState = .error // If no products are loaded, set the state to error.
            } else {
                loadState = .loaded // If products are loaded, set the state to loaded.
            }
        } catch {
            // If an error occurs, set the load state to error.
            loadState = .error
        }
    }

    /// Restores previous purchases from the App Store by syncing with the App Store account.
    /// - Uses `AppStore.sync()` to sync and restore purchases asynchronously.
    func restore() {
        Task {
            try await AppStore.sync()
        }
    }
}

#Preview {
    StoreView()
}
