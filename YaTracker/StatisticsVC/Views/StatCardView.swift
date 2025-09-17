//
//  StatCardView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 15.09.2025.
//

import SwiftUI

struct StatCardView: View {
    @State private var gradientStart = UnitPoint(x: -1, y: 0.5)
    @State private var gradientEnd = UnitPoint(x: 2, y: 0.5)
    
    let data: [ (String, Int) ]
    
    var body: some View {
        ForEach(data, id: \.0) { (title, value) in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .yellow, .green, .blue]),
                            startPoint: gradientStart,
                            endPoint: gradientEnd
                        ),
                        lineWidth: 2
                    )
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(value)").font(.system(size: 34, weight: .bold))
                        Text(title).font(.system(size: 12, weight: .medium))
                    }
                    Spacer()
                }
                .padding(12)
            }
            .frame(height: 90)
            .padding(.horizontal, 16)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                gradientStart = UnitPoint(x: 1, y: 0.5)
                gradientEnd = UnitPoint(x: 0, y: 0.5)
            }
        }
        Spacer()
    }
}
