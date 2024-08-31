//
//  UniDic.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 28/08/2024.
//

import Foundation
import Dictionary

import Foundation

public struct UniDic: DictionaryProviding {
    public let url: URL
    
    public init(url: URL? = nil) {
        if let providedURL = url {
            self.url = providedURL
        } else {
            /// Attempt to find the UniDic folder in the main bundle
            if let bundleURL = Bundle.main.url(forResource: "unidic_dictionary", withExtension: nil) {
                self.url = bundleURL
            } else {
                /// Fallback to a default location
                self.url = URL(fileURLWithPath: "PiPlex/Resources/UniDic/unidic_dictionary")
            }
        }
        
        /// Verify that the URL points to a directory
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: self.url.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            fatalError("UniDic URL does not point to a valid directory: \(self.url.path)")
        }
    }
    
    public var description: String {
        return "Dictionary: \(url), Type: UniDic"
    }
    
    public var dictionaryFormIndex: Int {
        return 6
    }
    
    public var readingIndex: Int {
        return 9
    }
    
    public var pronunciationIndex: Int {
        return 7
    }
    
    public func partOfSpeech(posID: UInt16) -> PartOfSpeech {
        /// Implement UniDic-specific part of speech mapping
        switch posID {
        case 0...10:
            return .noun
        case 11...20:
            return .verb
        case 21...30:
            return .adjective
        case 31...40:
            return .adverb
        case 41...50:
            return .particle
        default:
            return .unknown
        }
    }
}
