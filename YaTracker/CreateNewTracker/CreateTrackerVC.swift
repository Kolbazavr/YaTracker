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
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategory: String?
    
    private var footerView: UIView?
    
    private let maxTextLength: Int
    private let headerTitle = UILabel()
    private let tableView: MenuTableView
    private let decorCollectionView: DecorCollectionView
    
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
        self.decorCollectionView = DecorCollectionView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableViewItems()
        checkIsAllFieldsFilled()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard footerView == nil else { return }
        footerView = ButtonsView(buttons: [cancelButton, doneButton], frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60 + 16))
        tableView.tableFooterView = footerView
    }
    
    private func setupTableViewItems() {
        let menuItem1: MenuItem = .textField(placeholder: "Введите название трекера", limit: maxTextLength)
        let menuItem2: MenuItem = .navigationLink(title: "Категория", description: nil, destination: .categories)
        let menuItem3: MenuItem = .navigationLink(title: "Расписание", description: nil, destination: .schedule)
        let menuItem4: MenuItem = .decorCollection(collectionDelegate: self)
        
        let allMenuItems: [MenuItem] = [menuItem1, menuItem2, menuItem3, menuItem4]
        
        tableView.menuSelectionDelegate = self
        tableView.menuTextFieldDelegate = self
        tableView.addMenuItems(allMenuItems)
    }
    
    private func checkIsAllFieldsFilled() {
        doneButton.isEnabled =
        trackerName != nil &&
        trackerName != "" &&
        !selectedWeekDays.isEmpty &&
        selectedCategory != nil &&
        selectedEmoji != nil &&
        selectedColor != nil
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
            color: selectedColor ?? .black,
            emoji: selectedEmoji ?? "",
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

extension CreateTrackerVC: DecorCollectionViewDelegate {
    func didTapedOnDecor(_ decor: DecorType, wasSelected: Bool) {
        switch decor {
        case .emoji(let string):
            selectedEmoji = wasSelected ? string : nil
        case .colorHex(let string):
            selectedColor = wasSelected ? UIColor(hexString: string) : nil
        }
        checkIsAllFieldsFilled()
    }
}

extension CreateTrackerVC: ScheduleVCDelegate {
    func didSelectWeekDays(_ weekDay: Set<WeekDay>) {
        selectedWeekDays = weekDay
        let scheduleString = WeekDay.daysString(from: weekDay)
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
