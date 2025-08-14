//
//  TrackersViewController.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 29.07.2025.
//

import UIKit

protocol DateTextFieldDelegate: AnyObject {
    var isCalendarVisible: Bool { get }
    func showCalendar()
    func hideCalendar()
}

protocol CalendarViewDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

final class TrackersViewController: UIViewController {
    
    typealias TrackerDataSource = UICollectionViewDiffableDataSource<TrackerCategory, Tracker>
    typealias TrackerSnapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>
    
    private var collectionView: UICollectionView!
    private var dataSource: TrackerDataSource!
   
    private var selectedDate: Date = Date().onlyDate
    private var completedTrackers: Set<TrackerRecord> = []
    private var categories: Set<TrackerCategory> = [] { didSet { search(.byDay(WeekDay(from: selectedDate))) } }
    private var filteredCategories: [TrackerCategory] = [] { didSet { showStub(filteredCategories.isEmpty) } }
    
    private enum SearchCondition {
        case byDay(WeekDay)
        case byName(String)
    }
    
    private let trackerDataProvider: DataProvider
    private let headerHeight = CGFloat(30)
    
    init(dataProvider: DataProvider) {
        self.trackerDataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
        dataProvider.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var dateTextField: DateTextField = {
        let textField = DateTextField(maxLength: 6, onSearchAction: searchDateInCalendar)
        textField.dateTextFieldDelegate = self
        return textField
    }()
    
    private lazy var searchTextField: SearchTextField = {
        let searchTextField = SearchTextField(placeholder: "Поиск", maxLength: 15, onSearchAction: { [weak self] name in self?.search(.byName(name)) })
        return searchTextField
    }()
    
    private lazy var calendarView: CalendarView = {
        let calendarView = CalendarView(frame: .zero)
        calendarView.calendarViewDelegate = self
        return calendarView
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .ypBlack
        button.setImage(UIImage(resource: .plusButton), for: .normal)
        button.addTarget(self, action: #selector(addNewTracker), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.text = "Трекеры"
        return label
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        label.text = "Что будем отслеживать?"
        return label
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .emptyState))
        return imageView
    }()
    
    private lazy var tapDetector: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configCollectionView()
        configureDataSource()
        
        categories = Set(trackerDataProvider.fetchCategories())
        showStub(filteredCategories.isEmpty)
        tapDetector.isUserInteractionEnabled = false
    }
    
    private func showStub(_ show: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.emptyStateLabel.isHidden = !show
            self?.emptyStateImageView.isHidden = !show
        }
    }
    
    private func searchDateInCalendar(_ date: Date) {
        calendarView.selectDate(date)
        selectedDate = date.onlyDate
    }
    
    private func search(_ condition: SearchCondition ) {
        tapDetector.isUserInteractionEnabled = true
        let trackersOnThisDay: [String: [Tracker]] = categories.reduce(into: [:]) { result, category in
            result[category.title] = category.trackers.filter {
                return switch condition {
                case .byDay(let weekDay): $0.schedule.contains(weekDay)
                case .byName(let title): title.isEmpty ? $0.schedule.contains(WeekDay(from: selectedDate)) : $0.name.lowercased().contains(title.lowercased()) && $0.schedule.contains(WeekDay(from: selectedDate))
                }
            }
            result = result.filter { !$1.isEmpty }
        }
        filteredCategories = trackersOnThisDay.map { TrackerCategory(title: $0.key, trackers: $0.value) }
        applySnapshot(for: filteredCategories)
    }
    
    @objc private func addNewTracker() {
        let createTrackerViewController = CreateTrackerVC(dataProvider: trackerDataProvider)
        createTrackerViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: createTrackerViewController)
        navigationController.modalPresentationStyle = .automatic
        navigationController.navigationBar.isHidden = true
        present(navigationController, animated: true)
    }
    
    @objc private func dismissEditingThingys() {
        view.endEditing(true)
        if !calendarView.isHidden { hideCalendar() }
        tapDetector.isUserInteractionEnabled = false
    }
}

extension TrackersViewController: CreateTrackerVCDelegate {
    func didCreatedNewTracker(_ tracker: Tracker, in category: String) {
        trackerDataProvider.addTracker(tracker, to: category)
        searchTextField.text = nil
    }
}

extension TrackersViewController: DateTextFieldDelegate {
    var isCalendarVisible: Bool { !calendarView.isHidden }
    
    func showCalendar() {
        view.endEditing(true)
        
        calendarView.selectDate(selectedDate)
        calendarView.isHidden = false
        calendarView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        calendarView.alpha = 0
        
        tapDetector.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.2) {
            self.calendarView.transform = .identity
            self.calendarView.alpha = 1
        }
    }
        
    func hideCalendar() {
        tapDetector.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.calendarView.alpha = 0
        }) { _ in
            self.calendarView.isHidden = true
            self.dateTextField.setDate(self.selectedDate)
        }
    }
}

extension TrackersViewController: CalendarViewDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date.onlyDate
        dateTextField.setDate(date)
        search(.byDay(WeekDay(from: date)))
        hideCalendar()
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func didTapTrackerCell(with tracker: Tracker) {
        trackerDataProvider.toggleRecord(for: tracker.id, on: selectedDate)
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([tracker])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension TrackersViewController: TrackerDataProviderDelegate {
    func didUpdate() {
        categories = Set(trackerDataProvider.fetchCategories())
        applySnapshot(for: filteredCategories)
        tapDetector.isUserInteractionEnabled = false
    }
}


extension TrackersViewController {
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<TrackerCellCard, Tracker> { cell, indexPath, tracker in
            let recordsCount = self.trackerDataProvider.getCompletedTrackersCount(for: tracker.id)
            let isCompletedToday = self.trackerDataProvider.isTrackerCompletedToday(tracker.id, date: self.selectedDate)
            
            let enableButton = self.selectedDate <= Date()
            cell.configure(with: tracker, isCompletedToday: isCompletedToday, daysCompleted: recordsCount, enableButton: enableButton)
            cell.delegate = self
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<CollectionViewHeader>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, _, indexPath in
            let category = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            headerView.configure(with: category.title)
        }
        
        dataSource = TrackerDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, tracker in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: tracker)
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            kind == UICollectionView.elementKindSectionHeader ? collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath) : nil
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90 + 58))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(9)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(headerHeight))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func applySnapshot(for categories: [TrackerCategory], animated: Bool = true) {
        var snapshot = TrackerSnapshot()
        snapshot.appendSections(categories)
        categories.forEach { snapshot.appendItems($0.trackers, toSection: $0) }
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension TrackersViewController {
    private func configCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(collectionView, belowSubview: tapDetector)
        
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(emptyStateImageView)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -16),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        let topStackView = UIStackView(arrangedSubviews: [plusButton, dateTextField])
        topStackView.axis = .horizontal
        topStackView.distribution = .equalSpacing
        
        let tapRecognizer: UITapGestureRecognizer = .init(target: self, action: #selector(dismissEditingThingys))
        tapRecognizer.cancelsTouchesInView = false
        tapDetector.addGestureRecognizer(tapRecognizer)
        
        [searchTextField, trackersLabel, tapDetector, topStackView, calendarView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            dateTextField.heightAnchor.constraint(equalToConstant: 34),
            dateTextField.widthAnchor.constraint(equalToConstant: 77),
            
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            topStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackersLabel.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 5),
            trackersLabel.heightAnchor.constraint(equalToConstant: 41),
            trackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tapDetector.topAnchor.constraint(equalTo: view.topAnchor),
            tapDetector.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tapDetector.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tapDetector.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchTextField.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            calendarView.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.heightAnchor.constraint(greaterThanOrEqualToConstant: 325),
            ])
    }
}
