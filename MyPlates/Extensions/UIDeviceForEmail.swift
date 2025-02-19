//
//  UIDeviceForEmail.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 18.02.2025.
//

import Foundation
import UIKit

extension UIDevice {
    /// A structure representing a device model, used for mapping device identifiers to human-readable names.
    struct DeviceModel: Decodable {
        let identifier: String // The device's unique identifier string (e.g., "iPhone14,5")
        let model: String // The corresponding human-readable model name (e.g., "iPhone 13")
        /// Loads all known device models from a JSON file in the app bundle.
        static var all: [DeviceModel] {
            Bundle.main.decode([DeviceModel].self, from: "DeviceModels.json")
        }
    }

    /// A computed property that returns the human-readable model name of the current device.
    /// - If running in a simulator, it retrieves the model identifier from the environment.
    /// - Otherwise, it fetches the real device's identifier from system information.
    /// - The identifier is then matched against a JSON file containing known device models.
    /// - If the model is not found in the JSON, it defaults to returning the raw identifier string.
    var modelName: String {
        #if targetEnvironment(simulator)
        // Retrieves the device identifier for a simulator from the system environment variables.
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
        // Fetches system information to determine the real device's identifier.
        var systemInfo = utsname()
        uname(&systemInfo) // Populates systemInfo with device information.
        // Extracts the identifier string from the system info structure.
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif
        // Matches the extracted identifier to a known model name from the JSON file.
        // If no match is found, the raw identifier is returned instead.
        return DeviceModel.all.first {$0.identifier == identifier }?.model ?? identifier
    }
}
