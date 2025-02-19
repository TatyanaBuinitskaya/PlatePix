//
//  BundleForEmail.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 18.02.2025.
//

import Foundation

extension Bundle {
    /// Returns the display name of the application.
    /// It retrieves the value for the key "CFBundleName" from the app's Info.plist.
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Could not determine the application name"
    }
    /// Returns the build number of the application.
    /// It retrieves the value for the key "CFBundleVersion" from the app's Info.plist.
    var appBuild: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Could not determine the application build number"
    }
    /// Returns the short version string of the application.
    /// It retrieves the value for the key "CFBundleShortVersionString" from the app's Info.plist.
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Could not determine the application version"
    }

    /// Decodes a JSON file from the bundle into an instance of the specified Decodable type.
        ///
        /// - Parameters:
        ///   - type: The type that conforms to `Decodable` to which the JSON data should be decoded.
        ///   - file: The name of the JSON file (with extension) in the bundle.
        ///   - dateDecodingStategy: The strategy to decode date values (default is `.deferredToDate`).
        ///   - keyDecodingStrategy: The strategy to decode keys (default is `.useDefaultKeys`).
        /// - Returns: An instance of the specified type, decoded from the JSON file.
        /// - Note: The function uses `fatalError` if it fails to locate, load, or decode the file.
    func decode<T: Decodable>(_ type: T.Type,
                              from file: String,
                              dateDecodingStategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                              keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        // Attempt to locate the file in the bundle.
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Error: Failed to locate \(file) in bundle.")
        }
        // Attempt to load data from the file.
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Error: Failed to load \(file) from bundle.")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        // Attempt to decode the data into the specified type.
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Error: Failed to decode \(file) from bundle.")
        }
        return loaded
    }
}
