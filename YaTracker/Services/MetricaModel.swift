//
//  MetricaModel.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 15.09.2025.
//

import Foundation

struct MetricaModel {
    let event: EventType
    let screen: ScreenType
    let item: ItemType
    
    enum ScreenType: String {
        case main = "Main"
    }
    
    enum EventType: String {
        case open
        case close
        case click
    }
    
    enum ItemType: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
        case none
    }
}
