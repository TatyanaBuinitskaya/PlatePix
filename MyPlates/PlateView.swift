//
//  PlateView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//
import PhotosUI
import SwiftUI

struct PlateView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var plate: Plate
    @State private var pickerItems = [PhotosPickerItem]()
   // @State private var selectedImages = [Image]()
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $plate.plateTitle, prompt: Text("Enter the plate title here"))
                        .font(.title)
                    PhotosPicker(selection: $pickerItems, maxSelectionCount: 3, matching: .any(of: [.images, .not(.screenshots)])){
                        Label("Select a picture", systemImage: "photo")
                    }

                    Text("**Modified:** \(plate.plateModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    // if needed?
                    Text("**Status:** \(plate.plateStatus)")
                        .foregroundStyle(.secondary)

                }

                Picker("Meal Quality", selection: $plate.quality) {
                    Text("Bad").tag(Int16(0))
                    Text("Ok").tag(Int16(1))
                    Text("Great").tag(Int16(2))
                }
                Menu {
                    // show selected tags first
                    ForEach(plate.plateTags) { tag in
                        Button {
                            plate.removeFromTags(tag)
                        } label: {
                            Label(tag.tagName, systemImage: "checkmark")
                        }
                    }

                    // now show unselected tags
                    let otherTags = dataController.missingTags(from: plate)

                    if otherTags.isEmpty == false {
                        Divider()

                        Section("Add Tags") {
                            ForEach(otherTags) { tag in
                                Button(tag.tagName) {
                                    plate.addToTags(tag)
                                }
                            }
                        }
                    }
                } label: {
                    Text(plate.plateTagsList)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(nil, value: plate.plateTagsList)
                }
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("Notes", text: $plate.plateNotes, prompt: Text("Enter the plate description here"), axis: .vertical)
                }
            }
        }
        .disabled(plate.isDeleted)
        .onReceive(plate.objectWillChange) { _ in
            dataController.queueSave()
        }
    }
}

#Preview {
    PlateView(plate: .example)
}
