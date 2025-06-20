//
//  StoreView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 11.02.2025.
//

import RevenueCat
import SwiftUI

struct StoreView: View {
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// Access to the shared `DataController` instance.
    @EnvironmentObject var dataController: DataController
    /// Environment property to allow dismissing the store view.
    @Environment(\.dismiss) var dismiss
    /// The environment property that rovides access to the environment's `openURL` action, used to open external links.
    @Environment(\.openURL) var openURL
    /// The current offering retrieved from RevenueCat, which contains available subscription packages.
    @State var currentOffering: Offering?
    /// Tracks whether a purchase process is in progress.
    @State var isPurchasing = false
    /// A state variable to control whether the alert is shown or not.
    @State private var showAlert = false
    /// A state variable that holds the message to be displayed in the alert.
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Display the unlock image and title promoting the upgrade
                    VStack {
                        Spacer()
                        Text("Free version allows up to 35 plates")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .padding(0)
                        Spacer()
                        Text("Get unlimited plates with Premium")
                            .font(.title.bold())
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 400)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 40)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("GirlsPink"), Color("LavenderRaf")]),
                            startPoint: .top,
                            endPoint: .bottom)
                    )

                        Spacer()
                        VStack {
                            Text("Unlock Now")
                                .font(.title2)
                            if currentOffering != nil {
                                ForEach(currentOffering!.availablePackages) {pkg in
                                    Button {
                                        isPurchasing = true
                                        Purchases.shared.purchase(package: pkg) {(transaction, customerInfo, error, userCancelled) in
                                            if customerInfo?.entitlements["premium"]?.isActive == true {
                                                dataController.isSubscriptionIsActive = true
                                                isPurchasing = false
                                                dismiss()
                                                if !dataController.showStoreFromSettings {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        if dataController.newPlate() == true {
                                                            dataController.isNewPlateCreated = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Spacer()
                                            Text("\(pkg.storeProduct.localizedPriceString) / ")
                                                .font(.title2)

                                            Text("\(pkg.storeProduct.subscriptionPeriod!.periodTitle)")
                                                .font(.title2.bold())
                                                .fontDesign(.rounded)
                                            Spacer()
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 15)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(colorManager.selectedColor.color), in: .capsule)
                                        .contentShape(.rect)
                                        .padding(.vertical, 15)
                                    }
                                }
                            }
                            Text("You can cancel your subscription at any time")
                                .font(.caption)
                                .padding(.top, 0)
                        }
                        .padding(20)

                    Spacer()
                    // Button for restoring previous purchases
                    Button("Restore Purchases", action: restore)
                        .font(.title2)
                        .foregroundStyle(Color("LavenderRaf"))
                        .padding(.vertical, 15)
                    HStack {
                        Spacer()
                        Button("Terms And Conditions") {
                            if let urlTerms = URL(string: "https://tatyanabuinitskaya.github.io/PlatePixTerms/") {
                                openURL(urlTerms)
                            }
                        }
                        Spacer()
                        Button("Privacy Policy") {
                            // swiftlint:disable:next line_length
                            if let urlPolicy = URL(string: "https://tatyanabuinitskaya.github.io/PlatePixPrivacyPolicy/") {
                                openURL(urlPolicy)
                            }
                        }
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundStyle(Color("LavenderRaf"))
                    .padding(.bottom, 10)
                }

                Rectangle()
                    .foregroundStyle(Color.black)
                    .opacity(isPurchasing ? 0.5 : 0.0)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            Purchases.shared.getOfferings {offerings, error in
                if let offer = offerings?.current, error == nil {
                    currentOffering = offer
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Subscription Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    /// Restores previous purchases from the App Store by syncing with the App Store account.
    /// - Uses `AppStore.sync()` to sync and restore purchases asynchronously.
    func restore() {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                // Show an alert with the error message if restore fails
                showAlert(message: NSLocalizedString("Restore failed: \(error.localizedDescription)", comment: ""))
                return
            }

            if customerInfo?.entitlements.all["premium"]?.isActive == true {
                // Dismiss the store sheet and show success alert
                dataController.isSubscriptionIsActive = true
                dismiss()
                showAlert(message: NSLocalizedString("Your purchase has been successfully restored.", comment: ""))

                if !dataController.showStoreFromSettings {
                    // Delay the new plate presentation slightly for a smoother UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if dataController.newPlate() == true {
                            dataController.isNewPlateCreated = true
                        }
                    }
                }
            } else {
                // Show an alert if the user does not have active entitlements
                showAlert(message: NSLocalizedString("No active subscription found. Please purchase a subscription.", comment: ""))
            }
        }
    }

    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview("English") {
    StoreView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    StoreView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
