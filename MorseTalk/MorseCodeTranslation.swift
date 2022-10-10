//
//  MorseCodeTranslation.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 10/8/22.
//

import SwiftUI

struct MorseCode: Identifiable {
    let id: UUID = UUID()
    var codeType: CodeType
    
    enum CodeType: String, CaseIterable {
        case dot = "."
        case dash = "-"
        case wordSpace, charSpace
    }
    
    init(_ codeType: CodeType) {
        self.codeType = codeType
    }
}

class MorseCodeTranslation {
    var translatedText = "" {
        didSet {
            if translatedText != "" {
                print("Translation: \(translatedText)")
            }
        }
    }
    
    var morseCode = [MorseCode]() {
        didSet { print(morseCode) }
    }
    
    func processTranslation() {
        var newText = ""
        let words = morseCode.split(whereSeparator: { $0.codeType == .wordSpace }).map({ Array($0) })
        for word in words {
            let charCodes = word.split(whereSeparator: { $0.codeType == .charSpace }).map({ Array($0) })
            for char in charCodes {
                var morseString = ""
                char.forEach { code in
                    morseString += code.codeType.rawValue
                }
                if let translatedChar = AppConstants.translationAlphabets[morseString] {
                    newText += translatedChar
                }
            }
            newText += " "
        }
        if newText != translatedText {
            translatedText = newText
        }
    }
    
}
