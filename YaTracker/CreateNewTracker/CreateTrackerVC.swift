//
//  CreateTrackerVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

protocol MenuTableViewDelegate: AnyObject {
    func didSelectMenuItem(_ menuItem: MenuItem, at cell: MenuCell?)
}

protocol MenuTextFieldDelegate: AnyObject {
    func checkTrackerName(_ text: String)
}

protocol CreateTrackerVCDelegate: AnyObject {
    func didCreatedNewTracker(_ tracker: Tracker, in category: String)
}

final class CreateTrackerVC: UIViewController {
    
    weak var delegate: CreateTrackerVCDelegate?
    
    private var trackerName: String?
    private var selectedWeekDays: Set<WeekDay> = []
    private var selectedCategory: String?
    
    private let maxTextLength: Int
    private let headerTitle = UILabel()
    private let tableView: MenuTableView
    
    private lazy var doneButton: UIButton = {
        let button = DoneButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = CancelButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    init(textLimit: Int = 38) {
        self.maxTextLength = textLimit
        self.tableView = MenuTableView(texFieldsLimit: self.maxTextLength)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewItems()
        checkIsAllFieldsFilled()
        setupUI()
    }
    
    private func setupTableViewItems() {
        let menuItem1: MenuItem = .textField(placeholder: "Введите название трекера", limit: maxTextLength)
        let menuItem2: MenuItem = .navigationLink(title: "Категория", description: nil, destination: .categories)
        let menuItem3: MenuItem = .navigationLink(title: "Расписание", description: nil, destination: .schedule)
        
        let allMenuItems: [MenuItem] = [menuItem1, menuItem2, menuItem3]
        
        tableView.addMenuItems(allMenuItems)
        tableView.menuSelectionDelegate = self
        tableView.menuTextFieldDelegate = self
    }
    
    private func checkIsAllFieldsFilled() {
        doneButton.isEnabled = trackerName != nil && trackerName != "" && !selectedWeekDays.isEmpty && selectedCategory != nil
    }
    
    private func navigate(to destination: NavDestination) {
        let vc = switch destination {
        case .categories: CategoryListVC(delegate: self)
        case .schedule: ScheduleVC(selectedWeekDays: selectedWeekDays, delegate: self)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapDoneButton() {
        guard let trackerName, let selectedCategory, !selectedWeekDays.isEmpty else { return }
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .colorSelection15,
            emoji: "🏄🏼",
            schedule: selectedWeekDays.sorted(),
            isPinned: false
        )
        delegate?.didCreatedNewTracker(newTracker, in: selectedCategory)
        dismiss(animated: true)
    }
 
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension CreateTrackerVC: MenuTableViewDelegate {
    func didSelectMenuItem(_ menuItem: MenuItem, at cell: MenuCell?) {
        switch menuItem {
        case .textField:
            cell?.selectTextField()
        case .navigationLink(_ , _, destination: let destination):
            navigate(to: destination)
        default : break
        }
    }
}

extension CreateTrackerVC: MenuTextFieldDelegate {
    func checkTrackerName(_ text: String) {
        trackerName = text.trimmingCharacters(in: .whitespacesAndNewlines)
        checkIsAllFieldsFilled()
    }
}

extension CreateTrackerVC: ScheduleVCDelegate {
    func didSelectWeekDays(_ weekDay: Set<WeekDay>) {
        selectedWeekDays = weekDay
        
        let scheduleString = weekDay.count == 7 ? "Каждый день" : weekDay.sorted().map { $0.shortName } .joined(separator: ", ")
        
        tableView.updateDescriprion(at: IndexPath(row: 1, section: 1), with: scheduleString)
        checkIsAllFieldsFilled()
    }
}

extension CreateTrackerVC: CategoryListVCDelegate {
    func didSelectCategory(categoryTitle: String) {
        selectedCategory = categoryTitle
        tableView.updateDescriprion(at: IndexPath(row: 0, section: 1), with: categoryTitle)
        checkIsAllFieldsFilled()
    }
}

extension CreateTrackerVC {
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        let tapRecognizer: UITapGestureRecognizer = .init(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        headerTitle.text = "Новая привычка"
        headerTitle.font = .systemFont(ofSize: 16, weight: .medium)
        headerTitle.textAlignment = .center
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerTitle)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let HStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [cancelButton, doneButton])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            return stackView
        }()
        HStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(HStackView)
        
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            HStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            HStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            HStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            HStackView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}
