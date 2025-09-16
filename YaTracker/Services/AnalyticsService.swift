//
//  AnalyticsService.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 15.09.2025.
//

import AppMetricaCore
import Foundation

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "20d2a60e-0bf8-4630-b948-858ded70e0d0") else { return }
        AppMetrica.activate(with: configuration)
    }
    
    func report(model: MetricaModel) {
        var params: [AnyHashable : Any] = [ "screen" : model.screen.rawValue ]
        
        switch model.item {
        case .none:
            break
        default :
            params["item"] = model.item.rawValue
        }
        
        AppMetrica.reportEvent(name: model.event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
