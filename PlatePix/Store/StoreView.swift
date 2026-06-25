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
                        Text("Free version allows up to 15 plates")
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
                        if let offering = currentOffering {
                            ForEach(offering.availablePackages) { pkg in
                                Button {
                                    isPurchasing = true
                                    Purchases.shared.purchase(package: pkg) {(transaction, customerInfo, error, userCancelled) in
                                        defer {
                                            DispatchQueue.main.async {
                                                   isPurchasing = false
                                               }
                                           }

                                           if userCancelled {
                                               return
                                           }

                                        if let error = error {
                                            print(error.localizedDescription)
                                            return
                                        }
                                        if customerInfo?.entitlements["premium"]?.isActive == true {
                                            DispatchQueue.main.async {
                                                dataController.isSubscriptionIsActive = true
                                                dismiss()
                                                if !dataController.showStoreFromSettings {
                                                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                           if let plate = dataController.newPlate() {
                                                               dataController.path.append(plate)
                                                           }
                                                       }
                                                   }
                                            }
                                        }
                                    }
                                } label: {
                                        HStack {
                                            Spacer()
                                                if let introDiscount = pkg.storeProduct.localizedIntroductoryPriceString {
                                                    Text("\(pkg.storeProduct.localizedPriceString)")
                                                        .font(.title3)
                                                        .strikethrough(color: Color("GirlsPink"))
                                                    
                                                    Text("\(introDiscount)")
                                                        .font(.title2.bold())
                                                    
                                                    //  Text("/ \(pkg.storeProduct.subscriptionPeriod!.periodTitle)")
                                                    Text("/ \(pkg.storeProduct.subscriptionPeriod?.periodTitle ?? "")")
                                                        .font(.title2)
                                                        .fontDesign(.rounded)
                                                    
                                                } else {
                                                    Text("\(pkg.storeProduct.localizedPriceString)")
                                                        .font(.title2.bold())
                                                    
                                                    Text("/ \(pkg.storeProduct.subscriptionPeriod?.periodTitle ?? "")")
                                                        .font(.title2)
                                                        .fontDesign(.rounded)
                                                }
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
                                .disabled(isPurchasing)
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
                .allowsHitTesting(!isPurchasing)
                
                if isPurchasing {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)

                        Text("Processing purchase...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
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
    }
    
    /// Restores previous purchases from the App Store by syncing with the App Store account.
    /// - Uses `AppStore.sync()` to sync and restore purchases asynchronously.
    func restore() {
        Purchases.shared.restorePurchases { customerInfo, error in
            
            if let error = error {
                showAlert(message: NSLocalizedString("Restore failed: \(error.localizedDescription)", comment: ""))
                return
            }
            
            if customerInfo?.entitlements.all["premium"]?.isActive == true {
                
                dataController.isSubscriptionIsActive = true
                dismiss()
                
                showAlert(message: NSLocalizedString("Your purchase has been successfully restored.", comment: ""))
                
                if !dataController.showStoreFromSettings {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        _ = dataController.newPlate()
                    }
                }
                
            } else {
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
