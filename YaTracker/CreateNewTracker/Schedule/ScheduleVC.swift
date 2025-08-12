//
//  ScheduleVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

protocol ScheduleVCDelegate: AnyObject {
    func didSelectWeekDays(_ weekDay: Set<WeekDay>)
}

final class ScheduleVC: UIViewController {
    
    weak var delegate: ScheduleVCDelegate?
    
    private var selectedWeekDays: Set<WeekDay>
    
    private let headerTitle = UILabel()
    private let tableView = MenuTableView()
    private lazy var doneButton: UIButton = {
        let button = DoneButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    init(selectedWeekDays: Set<WeekDay> = [], delegate: ScheduleVCDelegate? = nil) {
        self.selectedWeekDays = selectedWeekDays
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewItems()
        setupUI()
    }
    
    private func setupTableViewItems() {
        let allMenuItems: [MenuItem] = WeekDay.allCases.map { .weekDaySelector(toggle: selectedWeekDays.contains($0) ? true : false, day: $0) }
        tableView.addMenuItems(allMenuItems)
        tableView.menuSelectionDelegate = self
    }
    
    @objc private func didTapDoneButton() {
        delegate?.didSelectWeekDays(selectedWeekDays)
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        headerTitle.text = "Расписание"
        headerTitle.font = .systemFont(ofSize: 16, weight: .medium)
        headerTitle.textAlignment = .center
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerTitle)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerTitle.heightAnchor.constraint(equalToConstant: 79),
            
            tableView.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension ScheduleVC: MenuTableViewDelegate {
    func didSelectMenuItem(_ menuItem: MenuItem, at cell: MenuCell?) {
        guard case let .weekDaySelector(_, day) = menuItem, let cell else { return }
        let _ = selectedWeekDays.remove(day) ?? selectedWeekDays.insert(day).memberAfterInsert
        cell.toggleTheToggle()
    }
}
