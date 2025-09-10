//
//  BackgroundVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 26.08.2025.
//

import UIKit

final class BackgroundVC: UIViewController {
    
    private let circleSizes: [CGFloat] = [260, 400, 550, 710, 860]
    private let killMyEyes: Bool
    private let startSeizure: Bool
    private let imageView: UIImageView
    private let label: UILabel
    
    init(image: UIImage, text: String, isEyesCrackerOn: Bool = false, isSeizureStarterOn: Bool = false) {
        self.killMyEyes = isEyesCrackerOn
        self.startSeizure = isSeizureStarterOn
        
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        
        label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .ypBlackDay
        label.text = text

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if killMyEyes {
            setupRotatingThingy()
            view.backgroundColor = .ypBlue
            createWhiteThingy()
        }
        if startSeizure {
            setupMovingThingy()
            view.backgroundColor = .ypRed
            createWhiteThingy()
        }
    }
    
    private func setupMovingThingy() {
        let frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )
        let seizureStarterView = BrainMelterView(frame: frame)
        view.insertSubview(seizureStarterView, aboveSubview: imageView)
    }
    
    private func createWhiteThingy() {
        imageView.isHidden = true
        let topColor = UIColor.clear
        let bottomColor = UIColor.white.withAlphaComponent(0.8)
        
        let whiteGradient = CAGradientLayer()
        whiteGradient.type = .axial
        whiteGradient.colors = [topColor.cgColor, bottomColor.cgColor]
        whiteGradient.locations = [0.0, 1.0]
        whiteGradient.frame = view.bounds
        
        let gradientView = UIView(frame: view.bounds)
        gradientView.layer.addSublayer(whiteGradient)
        view.insertSubview(gradientView, belowSubview: label)
    }
    
    private func setupRotatingThingy() {
        let itemSize: CGFloat = 50
        for (index, size) in circleSizes.enumerated() {
            let frame = CGRect(
                x: (view.bounds.width - size) / 2,
                y: (view.bounds.height - size) / 2,
                width: size,
                height: size
            )
            let anotherEyesCrackerView = EyesCrackerView(
                frame: frame,
                itemView: EyesCrackerView.Items.allCases[index % EyesCrackerView.Items.allCases.count],
                itemsCount: 6 * (index + 1),
                itemSize: itemSize,
                rotationDirection: index % 2 == 0 ? 1 : -1
            )
            view.insertSubview(anotherEyesCrackerView, aboveSubview: imageView)
        }
        
        let centerLogo = EyesCrackerView.Items.practoLogo.view
        centerLogo.frame = CGRect(
            x: view.bounds.width / 2,
            y: view.bounds.height / 2,
            width: itemSize,
            height: itemSize
        )
        centerLogo.center.y -= itemSize / 2
        centerLogo.center.x -= itemSize / 2
        view.insertSubview(centerLogo, aboveSubview: imageView)
    }
    
    private func setup() {
        view.backgroundColor = .white
        
        [imageView, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            label.heightAnchor.constraint(equalToConstant: 86),
        ])
    }
    
}
