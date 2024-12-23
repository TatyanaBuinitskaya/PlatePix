//
//  DetailView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        VStack {
            if let plate = dataController.selectedPlate {
                PlateView(plate: plate)
            } else {
                NoPlateIView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView()
}
