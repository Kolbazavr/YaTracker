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
    
    var allMenuItems: [MenuItem] = []
    
    private var limitWarningShown: Bool = false
    private var texFieldsLimit: Int
    private let cellHeight = CGFloat(75)
    private let footerHeight = CGFloat(38)
    
    private lazy var footerWarningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.text = "Ограничение \(texFieldsLimit) символов"
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
        self.allMenuItems = menuItems
        reloadData()
    }
    
    func updateDescriprion(at indexPath: IndexPath, with description: String) {
        guard let cell = cellForRow(at: indexPath) as? MenuCell else { return }
        cell.updateDescriptionLabel(with: description)
    }
    
    private func setupTableView() {
        backgroundColor = .ypWhite
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        dataSource = self
        delegate = self
        register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
    }
    
    private func menuItems(for section: Int) -> [MenuItem] {
        allMenuItems.filter { $0.typeName == allMenuItems[section].typeName }
    }
}

extension MenuTableView: MenuCellDelegate {
    func userIsTypingSomeBullshit(_ text: String, _ limitReached: Bool) {
        menuTextFieldDelegate?.checkTrackerName(text)
        showLimitWarning(limitReached, limitWarningShown)
    }
    
    func showLimitWarning(_ limitReached: Bool, _ warningShown: Bool) {
        guard limitReached != warningShown else { return }
        beginUpdates()
        self.limitWarningShown = limitReached
        endUpdates()
    }
}

extension MenuTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems(for: section).count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Set(allMenuItems.map { $0.typeName }).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier, for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }
        let item = menuItems(for: indexPath.section)[indexPath.row]
        cell.configureCell(with: item, delegate: self)
        return cell
    }
}

extension MenuTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuItems(for: indexPath.section)[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath) as? MenuCell
        
        menuSelectionDelegate?.didSelectMenuItem(menuItem, at: selectedCell)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard case .textField = allMenuItems[section] else { return nil }
        return footerWarningLabel
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        limitWarningShown ? footerHeight : 0
    }
}
