//
//  MenuTableView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

final class MenuTableView: UITableView {
    
    weak var menuSelectionDelegate: MenuTableViewDelegate?
    weak var menuTextFieldDelegate: MenuTextFieldDelegate?
    
    var warningShown: Bool = false
    
    private var allMenuItems: [[MenuItem]] = []
    private var allCells: [[UITableViewCell]] = []
    private var menuProvider: ((IndexPath) -> UIMenu?)?
    private var texFieldsLimit: Int = 0
    
    private let cellHeight = CGFloat(75)
    private let footerHeight = CGFloat(38)
    private let decorCollectionHeight = CGFloat(204 + 34 + 204 + 34)
    
    private lazy var footerWarningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    init(frame: CGRect = .zero, texFieldsLimit: Int = 38) {
        self.texFieldsLimit = texFieldsLimit
        super.init(frame: frame, style: .insetGrouped)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addMenuItems(_ menuItems: [MenuItem]) {
        self.allMenuItems = separateToSections(menuItems)
        self.allCells = precreateAllCells()
        reloadData()
    }
    
    func addMenuProvider(_ provider: @escaping ((IndexPath) -> UIMenu?)) {
        self.menuProvider = provider
    }
    
    func updateDescriprion(at indexPath: IndexPath, with description: String) {
        guard let cell = cellForRow(at: indexPath) as? MenuCell else { return }
        cell.updateDescriptionLabel(with: description)
    }
    
    private func setupTableView() {
        backgroundColor = .ypWhite
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: CGFloat.leastNonzeroMagnitude))

        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        separatorColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .ypWhite : UIColor.separator
        }
        
        dataSource = self
        delegate = self
    }
    
    private func precreateAllCells() -> [[UITableViewCell]] {
        allMenuItems.map { section in
            section.map { item in
                if case let .decorCollection(tracker: tracker, onDecorSelected: onDecorSelected) = item {
                    let cell = MenuDecorCell(style: .default, reuseIdentifier: nil)
                    if let tracker {
                        let decorThings = [DecorType.emoji(tracker.emoji), DecorType.colorHex(tracker.colorHex)]
                        cell.configure(selectedDecor: decorThings, onDecorSelected: onDecorSelected)
                    } else {
                        cell.configure(selectedDecor: [], onDecorSelected: onDecorSelected)
                    }
                    return cell
                } else {
                    let cell = MenuCell(style: .default, reuseIdentifier: nil)
                    cell.configureCell(with: item, delegate: self)
                    return cell
                }
            }
        }
    }
    
    private func separateToSections(_ menuItems: [MenuItem]) -> [[MenuItem]] {
        menuItems.reduce(into: []) { result, item in
            result.last?.last?.typeName == item.typeName ? result[result.count - 1].append(item) :  result.append([item])
        }
    }
}

extension MenuTableView: MenuCellDelegate {
    func userIsTypingSomeBullshit(_ text: String, _ overLimit: Bool) {
        menuTextFieldDelegate?.checkTrackerName(text, isOverLimit: overLimit)
    }
    
    func showWarningFooter(with text: String, show: Bool) {
        beginUpdates()
        footerWarningLabel.text = text
        self.warningShown = show
        endUpdates()
    }
}

extension MenuTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allMenuItems[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        allMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        allCells[indexPath.section][indexPath.row]
    }
}

extension MenuTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = allMenuItems[indexPath.section][indexPath.row]
        return switch item {
        case .decorCollection: decorCollectionHeight
        default: cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = allMenuItems[indexPath.section][indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath) as? MenuCell
        
        menuSelectionDelegate?.didSelectMenuItem(menuItem, at: selectedCell)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard case .textField = allMenuItems[section].first else { return nil }
        return footerWarningLabel
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard case .textField = allMenuItems[section].first else { return 0 }
        return warningShown ? footerHeight : 0
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let menu = menuProvider?(indexPath) else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in menu })
    }
}
