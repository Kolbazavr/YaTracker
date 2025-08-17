//
//  MenuCell.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

protocol MenuCellDelegate: AnyObject {
    func userIsTypingSomeBullshit(_ text: String, _ overLimit: Bool)
}

final class MenuCell: UITableViewCell {
    
    static let reuseIdentifier = "NotSoUniqueIdentifierForMenuCells"
    
    weak var delegate: MenuCellDelegate?
    
    var menuItem: MenuItem?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlackDay
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGray
        return label
    }()
    
    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .ypBlue
        toggle.isUserInteractionEnabled = false
        return toggle
    }()
    
    private lazy var searchTextField: NewTrackerTextField = {
        let textField = NewTrackerTextField() { self.delegate?.userIsTypingSomeBullshit($0, $1) }
        return textField
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with cellItem: MenuItem, delegate: MenuCellDelegate?) {
        menuItem = cellItem
        self.delegate = delegate
        switch cellItem {
        case .textField(let placeholder, let limit):
            addTextField(placeholder: placeholder, limit: limit)
        case .navigationLink(let title, let description, let destination):
            addNavigationLink(title: title, description: description, destination: destination)
        case .weekDaySelector(toggle: let isOn, day: let weekDay):
            addWeekDay(weekDay: weekDay, toggle: isOn)
        default: break
        }
    }
    
    func updateDescriptionLabel(with text: String?) {
        descriptionLabel.text = text
    }
    
    func toggleTheToggle() {
        toggleSwitch.setOn(!toggleSwitch.isOn, animated: true)
    }
    
    func selectTextField() {
        searchTextField.becomeFirstResponder()
    }
    
    private func addTextField(placeholder: String?, limit: Int) {
        searchTextField.placeholder = placeholder
        searchTextField.maxLength = limit
        vStackView.addArrangedSubview(searchTextField)
    }
    
    private func addNavigationLink(title: String, description: String?, destination: NavDestination) {
        titleLabel.text = title
        vStackView.addArrangedSubview(titleLabel)
        descriptionLabel.text = description
        vStackView.addArrangedSubview(descriptionLabel)
        accessoryType = .disclosureIndicator
    }
    
    private func addWeekDay(weekDay: WeekDay, toggle: Bool) {
        titleLabel.text = weekDay.longName
        vStackView.addArrangedSubview(titleLabel)
        toggleSwitch.isOn = toggle
        hStackView.addArrangedSubview(toggleSwitch)
    }
}

extension MenuCell {
    private func setupCell() {
        backgroundColor = .ypBackgroundDay
        
        hStackView.addArrangedSubview(vStackView)
        contentView.addSubview(hStackView)
        
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            hStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
