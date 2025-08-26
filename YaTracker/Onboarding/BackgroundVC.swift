//
//  BackgroundVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 26.08.2025.
//

import UIKit

final class BackgroundVC: UIViewController {
    
    let imageView: UIImageView
    let label: UILabel
    
    init(image: UIImage, text: String) {
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
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
