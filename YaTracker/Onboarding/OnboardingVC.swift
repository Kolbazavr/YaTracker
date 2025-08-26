//
//  OnboardingVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 25.08.2025.
//

import UIKit

final class OnboardingVC: UIPageViewController {
    
    var onSkip: (() -> Void)?
    
    let firstPageText = "Отслеживайте только" + "\n" + "то, что хотите"
    let secondPageText = "Даже если это" + "\n" + "не литры воды и йога"
    
    private lazy var pages: [UIViewController] = {
        let first = BackgroundVC(image: UIImage(resource: .onboarding1), text: firstPageText)
        let second = BackgroundVC(image: UIImage(resource: .onboarding2), text: secondPageText)
        return [first, second]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        return pageControl
    }()
    
    private lazy var skipButton: UIButton = {
        let button = DoneButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageVC()
        setup()
    }
    
    private func configurePageVC() {
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    private func setup() {
        [pageControl, skipButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -24),
            
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func skipButtonTapped() {
        onSkip?()
    }
}

extension OnboardingVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

extension OnboardingVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = viewControllers?.first, let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}
