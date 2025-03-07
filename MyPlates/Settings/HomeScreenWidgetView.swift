//
//  HomeScreenWidgetView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.02.2025.
//

import SwiftUI

/// A view that provides instructions for adding a widget to the Home Screen.
struct HomeScreenWidgetView: View {
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    
    var body: some View {
        VStack(alignment: .leading){
            Spacer()
            VStack {
                Text("Just a few steps to get")
                Text("daily motivations on your")
            }
            .font(.headline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top)
           
            VStack{
                Text("HOME SCREEN")
                    .font(.title.bold())
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity)
                    .frame(alignment: .center)
    
                // Home Screen Widget example section
                ZStack{
                    // A rounded rectangle with a shadow to create a card effect
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(colorManager.selectedColor.color)) // Fill with white color
                        .frame(height: 150)
                        .frame(maxWidth: 300)
                        .shadow(radius: 5)
                    // Motivational message displayed inside the card
                    Text("Small doses of motivation can make a big difference in your life")
                        .font(.title3)
                        .fontWeight(.regular)
                        .lineSpacing(5)
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .frame(maxWidth: 300)
                        .padding(15)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            .padding()
            
            // Instructions for Adding Widget
            // TODO: Change name of app and localize properly!
            VStack(alignment: .leading, spacing: 20) {
                Text("1. Touch and hold an empty area on the Home Screen until the apps jiggle.")
                Text("2. Tap the Edit button in the upper left corner then tap Add Widget to view available widgets, scroll or search for MyPlates widget.")
                Text("3. Press Add Widget button and place widget in the position you want, then tap the empty area to finish.")
            }
            .font(.callout)
            .fontWeight(.regular)
            .padding(20)
            Spacer()
            Spacer()
        }
    }
}

#Preview("English") {
    HomeScreenWidgetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    HomeScreenWidgetView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
