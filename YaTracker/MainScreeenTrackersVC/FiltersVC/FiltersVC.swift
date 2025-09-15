//
//  FiltersVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.09.2025.
//

import UIKit

protocol FiltersVCDelegate: AnyObject {
    func filtersVC(_ vc: FiltersVC, didSelectFilter filter: FilterType)
}

final class FiltersVC: UIViewController {
    
    weak var delegate: FiltersVCDelegate?
    
    private var selectedFilter: FilterType?
    private var isForToday: Bool
    
    private let headerTitle = UILabel()
    private let tableView = MenuTableView()
    
    init(isForToday: Bool, selectedFilter: FilterType? = nil) {
        self.isForToday = isForToday
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateMenu()
        setTableViewDelegate()
    }
    
    private func setTableViewDelegate() {
        tableView.menuSelectionDelegate = self
    }
    
    private func updateMenu() {
        let menuItems: [MenuItem] = FilterType.allCases.map { filter in
            let shouldBeSelected: Bool = switch filter {
            case .all: false
            case .active, .completed: selectedFilter?.stringValue == filter.stringValue
            case .today: isForToday && selectedFilter == .today
            }
            return .categorySelector(categoryTitle: filter.stringValue, isSelected: shouldBeSelected)
        }
        tableView.addMenuItems(menuItems)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        headerTitle.text = "Фильтры"
        headerTitle.font = .systemFont(ofSize: 16, weight: .medium)
        headerTitle.textAlignment = .center
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerTitle)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerTitle.heightAnchor.constraint(equalToConstant: 79),
            
            tableView.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
        ])
    }
}

extension FiltersVC: MenuTableViewDelegate {
    func didSelectMenuItem(_ menuItem: MenuItem, at cell: MenuCell?) {
        guard let cell, let indexPath = tableView.indexPath(for: cell) else { return }
        
        selectedFilter = FilterType.allCases[indexPath.row]
        isForToday = selectedFilter == .today
        
        updateMenu()
        delegate?.filtersVC(self, didSelectFilter: selectedFilter!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.dismiss(animated: true)
        }
    }
}
