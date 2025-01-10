//
//  AwardSheetView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 04.01.2025.
//

import SwiftUI

struct AwardSheetView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Congratulations!")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("You've earned the following awards:")
                .padding()
            
            if let lastAward = dataController.congratulatedAwards.last {
                Text("\(lastAward.name) Award!")
                Image(systemName: lastAward.image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: 100, height: 100)
                Text("\(lastAward.value)")
                
                Button(action: {
                    dataController.showCongratulations = false
                    dismiss()
                }) {
                    Text("OK")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

#Preview {
    AwardSheetView()
}
