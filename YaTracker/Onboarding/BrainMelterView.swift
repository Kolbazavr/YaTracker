//
//  SeizureStarterView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.08.2025.
//

import UIKit

final class BrainMelterView: UIView {
    
    private var displayLink: CADisplayLink?
    private var columnsTopYCoordinate: CGFloat = 0
    private var calculatedColumnHeight: CGFloat = 0
    
    private let spacingBetweenItems: CGFloat = 110
    private let itemSize: CGFloat
    private let numberOfColumns: Int = 7
    private let speed: CGFloat = 3.0
    
    private enum Items: CaseIterable {
        case fire
        case smile
        case practoLogo
        
        var view: UIView {
            return switch self {
            case .fire: {
                let starsLabel = UILabel()
                starsLabel.text = "🔥"
                return starsLabel
            }()
            case .smile: {
                let smileLabel = UILabel()
                smileLabel.text = "🥳"
                return smileLabel
            }()
            case .practoLogo: UIImageView(image: UIImage(resource: .launchScreenLogo))
            }
        }
    }
    
    init(frame: CGRect, itemSize: CGFloat = 35) {
        self.itemSize = itemSize
        super.init(frame: frame)
        clipsToBounds = true
        createPattern()
        startMoving()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createPattern() {
        let viewSequenceCount = Items.allCases.count
        let viewSequenceHeight = CGFloat(viewSequenceCount) * spacingBetweenItems
        
        let availableHeight = bounds.height + viewSequenceHeight / 2
        columnsTopYCoordinate = -viewSequenceHeight / 2
        
        let timesItWillFitOnScreen = Int(availableHeight / viewSequenceHeight)
        let timesItShouldFitOnScreen = timesItWillFitOnScreen + 1
        let requiredHeight = CGFloat(timesItShouldFitOnScreen) * viewSequenceHeight
        calculatedColumnHeight = requiredHeight
        
        let eachViewYPositions: [CGFloat] = stride(from: 0, to: calculatedColumnHeight, by: spacingBetweenItems ).map(\.self)
        let columnsXPositions = stride(from: -itemSize / 2 , to: bounds.width + itemSize / 2, by: (bounds.width + itemSize) / CGFloat(numberOfColumns)).map(\.self)
        let columnWidth = bounds.width / CGFloat(numberOfColumns)
        
        let columnViews = columnsXPositions.enumerated().map { columnIndex, x in
            let newColumn = UIView(frame: CGRect(x: x, y: columnsTopYCoordinate, width: columnWidth, height: calculatedColumnHeight))
            
            let viewsForColumn = eachViewYPositions.enumerated().map { viewIndex, y in
                let isVariableScaleColumn: Bool = columnIndex % 2 == 1
                
                let newView = switch isVariableScaleColumn {
                case true: Items.allCases[(viewIndex + columnIndex % 4) % viewSequenceCount].view
                case false: Items.allCases[viewIndex % viewSequenceCount].view
                }
                
                let shouldBeLarge = isVariableScaleColumn && viewIndex % 2 == 0
                
                newView.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: itemSize * (shouldBeLarge ? 2 : 1),
                    height: itemSize * (shouldBeLarge ? 2 : 1)
                )
                
                newView.center = CGPoint(x: columnWidth / 2, y: y)
                
                if newView is UILabel {
                    (newView as! UILabel).font = .systemFont(ofSize: itemSize * (shouldBeLarge ? 2 : 1))
                    (newView as! UILabel).textAlignment = .center
                }
                return newView
            }
            viewsForColumn.forEach { newColumn.addSubview($0) }
            return newColumn
        }
        columnViews.forEach { addSubview($0) }
    }
    
    private func startMoving() {
        displayLink = CADisplayLink(target: self, selector: #selector(updatePosition))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updatePosition() {
        for (columnIndex, column) in self.subviews.enumerated() {
            for view in column.subviews {
                view.center.y += speed * (columnIndex % 2 == 0 ? 1 : -1)

                if view.center.y > calculatedColumnHeight {
                    view.center.y = 0
                }
                
                if view.center.y < 0 {
                    view.center.y = calculatedColumnHeight
                }
            }
        }
    }
}

#Preview {
    BrainMelterView(frame: CGRect(x: 0, y: 0, width: 400, height: 1000), itemSize: 40)
}
