//
//  PlateBox.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import SwiftUI

struct PlateBox: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var plate: Plate
    
    var body: some View {
        NavigationLink(value: plate){
            VStack{
                Text(plate.plateTitle)
                Text(plate.plateTagsList)
                Image(systemName: plate.platePhoto)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                Text(plate.plateCreationDate.formatted(date: .omitted, time: .shortened))
                Text("\(plate.quality)")
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(plate.plateNotes)
            }
            
            Spacer()
            
        }
    }
}

#Preview {
    PlateBox(plate: .example)
}
