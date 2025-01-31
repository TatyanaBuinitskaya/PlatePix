//
//  NoPlateIView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import SwiftUI

struct NoPlateIView: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Text("No Plate Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        Button("New Plate", action: dataController.newPlate)
    }
}

#Preview {
    NoPlateIView()
}
