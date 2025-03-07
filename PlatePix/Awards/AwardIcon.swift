//
//  AwardIcon.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 25.02.2025.
//

import SwiftUI

/// A view that displays an award icon with a customizable size and color.
struct AwardIcon: View {
    /// The award data containing the value to be displayed.
    let award: Award
    /// The base size for scaling the entire icon proportionally.
    let size: CGFloat // Base size for scaling
    /// The color used for styling the rosette and text.
    let color: Color
    
    var body: some View {
        ZStack {
            // Background rosette image
            Image(systemName: "rosette")
                .resizable()
                .scaledToFit()
                .frame(width: size)
                .foregroundStyle(Color(color).gradient)

            // White circular overlay with a gray stroke
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.88, height: size * 0.88)
                .overlay(
                    Circle()
                        .stroke(Color("GrayMaterial"), lineWidth: size * 0.02)
                        .padding(size * 0.12)
                )
                .offset(y: -size * 0.2)

            // Award value text positioned within the overlay
            Text("\(award.value)")
                .font(size > 100 ? .title2 : .headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(color))
                .offset(y: -size * 0.2)
        }
    }
}

#Preview("English") {
    AwardIcon(award: .example, size: 125, color: Color("LavenderRaf"))
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    AwardIcon(award: .example, size: 125, color: Color("LavenderRaf"))
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
