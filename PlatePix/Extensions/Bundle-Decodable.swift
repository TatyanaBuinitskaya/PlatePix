//
//  Bundle-Decodable.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 24.12.2024.
//

import Foundation
// swiftlint:disable line_length
/// An extension of `Bundle` that provides a generic method for decoding JSON files into Swift types conforming to `Decodable`.
extension Bundle {
    /// Decodes a JSON file from the app bundle into a specified `Decodable` type.
        ///
        /// This method simplifies JSON decoding by providing default decoding strategies for dates and keys,
        /// while offering flexibility for customization when needed. It uses `fatalError` for error handling to
        /// immediately stop execution in case of a decoding failure, making it suitable for debugging or development environments.
        ///
        /// - Parameters:
        ///   - file: The name of the JSON file to decode, including its extension (e.g., `"data.json"`).
        ///   - type: The expected `Decodable` type to decode the JSON into. Defaults to the inferred type `T`.
        ///   - dateDecodingStrategy: The strategy to use when decoding `Date` values. Defaults to `.deferredToDate`.
        ///   - keyDecodingStrategy: The strategy to use when decoding keys. Defaults to `.useDefaultKeys`.
        ///
        /// - Returns: An instance of the specified type `T` containing the decoded data from the JSON file.
        ///
        /// - Note: This method is designed for simplicity and quick development. For production apps, consider using more robust error handling.
    func decode<T: Decodable>(
        _ file: String,
        as type: T.Type = T.self,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        // The URL of the JSON file in the bundle. Crashes if the file cannot be found to avoid silent failures.
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        // The raw data from the JSON file. Crashes if the file cannot be loaded, preventing decoding invalid data.

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        // The JSONDecoder instance configured with provided decoding strategies.
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        do {
            // Attempts to decode the data into the specified type `T`.
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            // Handles missing keys in the JSON structure, providing clear error feedback.
            fatalError("Failed to decode \(file): missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            // Handles type mismatches between the JSON data and the expected model structure.
            fatalError("Failed to decode \(file): type mismatch – \(context.debugDescription)") // swiftlint:disable line_length
        } catch DecodingError.valueNotFound(let type, let context) {
            // Handles cases where an expected non-optional value is missing in the JSON.
            fatalError(
                "Failed to decode \(file): missing \(type) value – \(context.debugDescription)"
            )
        } catch DecodingError.dataCorrupted(_) {
            // Handles corrupted or invalid JSON data.
            fatalError("Failed to decode \(file): invalid JSON")
        } catch {
            // Handles any other decoding errors that are not explicitly covered.
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
// swiftlint:enable line_length
