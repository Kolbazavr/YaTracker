//
//  CreateTrackerVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

@MainActor
protocol MenuTableViewDelegate: AnyObject {
    func didSelectMenuItem(_ menuItem: MenuItem, at cell: MenuCell?)
}

@MainActor
protocol MenuTextFieldDelegate: AnyObject {
    func checkTrackerName(_ name: String, isOverLimit: Bool)
}

protocol CreateTrackerVCDelegate: AnyObject {
    func didCreatedNewTracker(_ tracker: Tracker, in category: String)
}

final class CreateTrackerVC: UIViewController {
    
    weak var delegate: CreateTrackerVCDelegate?
    
    private var trackerToEdit: Tracker?
    private var isEditingTracker: Bool { trackerToEdit != nil }
    
    private var nameCheckingWorkItem: DispatchWorkItem?
    private var trackerName: String?
    private var selectedWeekDays: Set<WeekDay> = []
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategory: String?
    private var footerView: UIView?
    
    private let trackerStore: TrackerStoreProtocol
    private let categoryStore: TrackerCategoryStoreProtocol
    private let maxTextLength: Int
    private let headerTitle = UILabel()
    private let tableView: MenuTableView
    private let decorCollectionView: DecorCollectionView
    
    private enum WarningType {
        case nameLength(Int)
        case nameExists
        
        var message: String {
            return switch self {
            case .nameLength(let limit): String(format: NSLocalizedString("the_limit_is_N_characters", comment: "LimitWarning"), limit)
            case .nameExists: NSLocalizedString("already_exists", comment: "AlreadyExistsWarning")
            }
        }
    }
    
    private lazy var bigAssRecordsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = DoneButton(type: .system)
        button.setTitle(isEditingTracker ? NSLocalizedString("save", comment: "Save") : NSLocalizedString("create", comment: "Create"), for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = CancelButton(type: .system)
        button.setTitle(NSLocalizedString("cancel", comment: "Cancel"), for: .normal)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    init(trackerStore: TrackerStoreProtocol, categoryStore: TrackerCategoryStoreProtocol, textLimit: Int = 38, trackerToEdit: Tracker? = nil) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.maxTextLength = textLimit
        self.tableView = MenuTableView(texFieldsLimit: self.maxTextLength)
        self.decorCollectionView = DecorCollectionView()
        
        super.init(nibName: nil, bundle: nil)
        setupEditMode(for: trackerToEdit)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nameCheckingWorkItem?.cancel()
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
        let textFieldText = trackerToEdit?.name
        let selectedCategory = trackerStore.categoryName(with: trackerToEdit?.id)
        let scheduleDescription = isEditingTracker ? WeekDay.daysString(from: selectedWeekDays) : nil
        
        let menuItem1: MenuItem = .textField(placeholder: NSLocalizedString("enter_tracker_name", comment: "TrackerNamePlaceHolder"), limit: maxTextLength, text: textFieldText)
        let menuItem2: MenuItem = .navigationLink(title: NSLocalizedString("category", comment: "CategoryMenuItem"), description: selectedCategory, destination: .categories)
        let menuItem3: MenuItem = .navigationLink(title: NSLocalizedString("schedule", comment: "ScheduleMenuItem"), description: scheduleDescription, destination: .schedule)
        let menuItem4: MenuItem = .decorCollection(tracker: trackerToEdit) { [weak self] decor, isSelected in
            self?.didTapedOnDecor(decor, wasSelected: isSelected)
        }
        
        let allMenuItems: [MenuItem] = [menuItem1, menuItem2, menuItem3, menuItem4]
        
        tableView.menuSelectionDelegate = self
        tableView.menuTextFieldDelegate = self
        tableView.addMenuItems(allMenuItems)
    }
    
    private func setupEditMode(for tracker: Tracker?) {
        guard let tracker else { return }
        trackerToEdit = tracker
        trackerName = tracker.name
        selectedWeekDays = Set(tracker.schedule)
        selectedCategory = trackerStore.categoryName(with: tracker.id)
        selectedEmoji = tracker.emoji
        selectedColor = tracker.colorHex
    }
    
    private func didTapedOnDecor(_ decor: DecorType, wasSelected: Bool) {
        switch decor {
        case .emoji(let string):
            selectedEmoji = wasSelected ? string : nil
        case .colorHex(let string):
            selectedColor = wasSelected ? string : nil
        }
        checkIsAllFieldsFilled()
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
        case .categories: CategoryListVC(selectedCategory: selectedCategory, categoryStore: categoryStore, delegate: self)
        case .schedule: ScheduleVC(selectedWeekDays: selectedWeekDays, delegate: self)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapDoneButton() {
        guard let trackerName, let selectedCategory, !selectedWeekDays.isEmpty else { return }
        
        let newTracker = Tracker(
            id: trackerToEdit?.id ?? UUID(),
            name: trackerName,
            colorHex: selectedColor ?? "",
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
    func checkTrackerName(_ name: String, isOverLimit: Bool) {
        nameCheckingWorkItem?.cancel()
        let newWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var nameIsAllowed: Bool = false
            
            if trimmedName == trackerToEdit?.name {
                nameIsAllowed = true
            } else {
                nameIsAllowed = isOverLimit ? false : !trackerStore.checkTrackerNameExists(trimmedName)
            }
            
            trackerName = nameIsAllowed ? trimmedName : ""
            checkIsAllFieldsFilled()
            
            guard (isOverLimit || !nameIsAllowed) != tableView.warningShown else { return }
            let warningText = isOverLimit ? WarningType.nameLength(maxTextLength).message : WarningType.nameExists.message
            tableView.showWarningFooter(with: warningText, show: isOverLimit || !nameIsAllowed)
        }
        nameCheckingWorkItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: newWorkItem)
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
        
        headerTitle.text = isEditingTracker ? NSLocalizedString("edit_habit", comment: "EditHabitHeader") : NSLocalizedString("new_habit", comment: "NewHabitHeader")
        headerTitle.font = .systemFont(ofSize: 16, weight: .medium)
        headerTitle.textAlignment = .center
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerTitle)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        if isEditingTracker {
            bigAssRecordsCountLabel.text = trackerStore.getCompletedTrackersCount(for: trackerToEdit!.id).dayStringRU
            
            bigAssRecordsCountLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bigAssRecordsCountLabel)
            
            NSLayoutConstraint.activate([
                bigAssRecordsCountLabel.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 0),
                bigAssRecordsCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                bigAssRecordsCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                bigAssRecordsCountLabel.heightAnchor.constraint(equalToConstant: 38),
            ])
        }
        
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerTitle.heightAnchor.constraint(equalToConstant: 79),
            
            tableView.topAnchor.constraint(equalTo: isEditingTracker ? bigAssRecordsCountLabel.bottomAnchor : headerTitle.bottomAnchor, constant: isEditingTracker ? 40 : 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
        ])
    }
}
