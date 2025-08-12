//
//  Decorations.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 09.08.2025.
//

import Foundation

enum DecorType {
    case emoji(String)
    case colorHex(String)
    
    static var allEmojis: [DecorType] {
        Emojis.all.map { .emoji($0) }
    }
    
    static var allColors: [DecorType] {
        ColorSelection.all.map { .colorHex($0) }
    }
    
    private enum Emojis {
        static let all: [String] = [
            "🙂",
            "😻",
            "🌸",
            "🐶",
            "❤️",
            "😱",
            "😇",
            "😡",
            "🥶",
            "🤔",
            "🙌",
            "🍔",
            "🥦",
            "🏓",
            "🥇",
            "🎸",
            "🏝️",
            "🥲"
        ]
    }
    
    private enum ColorSelection {
        static let all: [String] = [
            "#FD4C49",
            "#FF881E",
            "#007BFA",
            "#6E44FE",
            "#33CF69",
            "#E66DD4",
            "#F9D4D4",
            "#34A7FE",
            "#46E69D",
            "#35347C",
            "#FF674D",
            "#FF99CC",
            "#F6C48B",
            "#7994F5",
            "#832CF1",
            "#AD56DA",
            "#8D72E6",
            "#2FD058"
        ]
    }
}
    
