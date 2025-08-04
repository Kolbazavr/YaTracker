//
//  MenuTableView.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

final class MenuTableView: UITableView {
    
    weak var menuDelegate: MenuTableViewDelegate?
    
    private var allMenuItems: [MenuItem] = []
    private let cellHeight = CGFloat(75)
    
    override init(frame: CGRect = .zero, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)
        setupTableView()
    }
    
     func addMenuItems(_ menuItems: [MenuItem]) {
        self.allMenuItems = menuItems
        reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        backgroundColor = .ypWhite
        
        dataSource = self
        delegate = self
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
    }
    
    private func menuItems(for section: Int) -> [MenuItem] {
        allMenuItems.filter { $0.typeName == allMenuItems[section].typeName }
    }
    
}

extension MenuTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems(for: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier, for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }
        let item = menuItems(for: indexPath.section)[indexPath.row]
        cell.configureCell(with: item)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let menuItemsTypes = Set(allMenuItems.map { $0.typeName })
        return menuItemsTypes.count
    }
}

extension MenuTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuItems(for: indexPath.section)[indexPath.row]
        
        let selectedCell = tableView.cellForRow(at: indexPath) as? MenuCell
        
        menuDelegate?.didSelectMenuItem(menuItem, at: selectedCell)
    }
}
