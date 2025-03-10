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
    /// The current offering retrieved from RevenueCat, which contains available subscription packages.
    @State var currentOffering: Offering?
    @State var isPurchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Display the unlock image and title promoting the upgrade
                    VStack {
                        
                        Text("Unlock Premium")
                            .font(.title.bold())
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                        Text("PlatePix")
                            .font(.system(size: 30, weight: .bold))
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                        
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .padding(0)
                        Text("Add as many plates as you want!")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(.bottom)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(colorManager.selectedColor.color.gradient)
                    
                    // Scrollable content section
                    ScrollView {
                        VStack {
                            Spacer(minLength: 30)
                            if currentOffering != nil {
                                ForEach(currentOffering!.availablePackages) {pkg in
                                    Button {
                                        isPurchasing = true
                                        Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
                                            if customerInfo?.entitlements["premium"]?.isActive == true {
                                                // Unlock that great "pro" content
                                                dataController.isSubscriptionIsActive = true
                                                
                                                isPurchasing = false
                                                // showingStore = false
//                                                if !userCancelled, error == nil {
//                                                   // dismiss()
//                                                } else if let error = error {
//                                                    self.error = error as NSError
//                                                    self.displayError = true
//                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Spacer()
                                            Text("\(pkg.storeProduct.localizedPriceString) / ")
                                                .font(.title)
                                            
                                            Text("\(pkg.storeProduct.subscriptionPeriod!.periodTitle)")
                                            
                                                .font(.title.bold())
                                                .fontDesign(.rounded)
                                            Spacer()
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 15)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(colorManager.selectedColor.color), in: .capsule)
                                        .contentShape(.rect)
                                        .padding(.vertical)
                                    }
                                }
                            }
                            Text("Cancel Anytime")
                        }
                        .padding(20)
                    }
                    
                    // Button for restoring previous purchases
                    Button("Restore Purchases", action: restore)
                        .font(.title2)
                        .foregroundStyle(Color(colorManager.selectedColor.color))
                        .padding(.vertical, 20)
                    HStack {
                        Spacer()
                        Button("Terms And Conditions") {
                            
                        }
                        Spacer()
                        Button("Privacy Policy") {
                            
                        }
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundStyle(Color(colorManager.selectedColor.color))
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
    }


    /// Restores previous purchases from the App Store by syncing with the App Store account.
    /// - Uses `AppStore.sync()` to sync and restore purchases asynchronously.
    func restore() {
        Purchases.shared.restorePurchases { customerInfo, error in
            dataController.isSubscriptionIsActive = customerInfo?.entitlements.all["Premium"]?.isActive == true
        }
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
