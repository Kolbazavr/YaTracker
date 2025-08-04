//
//  MenuCell.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

final class MenuCell: UITableViewCell {
    
//    weak var delegate: MenuCellDelegate?
    
    static let reuseIdentifier = "MenuCell"
    
    var textFieldText: String?
    var isToggleOn: Bool?
    
    private lazy var HStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var VStackView: UIStackView = {
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
    
    func configureCell(with cellItem: MenuItem) {
        switch cellItem {
        case .textField(let placeholder):
            addTextField(placeholder: placeholder)
        case .navigationLink(let title, let description, let destination):
            addNavigationLink(title: title, description: description, destination: destination)
        case .weekDay(text: let weekDay, toggle: let isOn):
//            addLabel(text: weekDay)
//            addToggle(isOn: isOn)
            addWeekDay(weekDay: weekDay, toggle: isOn)
        }
    }
    
    func toggleTheToggle() {
        guard let toggle = self.viewWithTag(100) as? UISwitch else { return }
        toggle.setOn(!toggle.isOn, animated: true)
    }
    
    private func addTextField(placeholder: String?) {
        let textField: UITextField = {
            let textField = UITextField()
            textField.placeholder = placeholder
            textField.textColor = .ypBlack
            textField.delegate = self
            return textField
        }()
        VStackView.addArrangedSubview(textField)
    }
    
    private func addNavigationLink(title: String, description: String?, destination: NavDestination) {
        addLabel(text: title)
        addLabel(text: description, color: .ypGray)
        accessoryType = .disclosureIndicator
    }
    
    private func addWeekDay(weekDay: String, toggle: Bool) {
        addLabel(text: weekDay)
        addToggle(isOn: toggle)
    }
    
    private func addLabel(text: String?, color: UIColor? = .ypBlackDay) {
        guard let text else { return }
        let label: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17, weight: .regular)
            label.textColor = color
            label.text = text
            return label
        }()
        VStackView.addArrangedSubview(label)
    }
    
    private func addToggle(isOn: Bool) {
        let toggle: UISwitch = {
            let toggle = UISwitch()
            toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
            toggle.tag = 100
            return toggle
        }()
        toggle.isOn = isOn
        HStackView.addArrangedSubview(toggle)
    }
    
    @objc private func toggleValueChanged(_ sender: UISwitch) {
        isToggleOn = sender.isOn
    }
}

extension MenuCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textFieldText = textField.text
        return true
    }
}

extension MenuCell {
    private func setupCell() {
        backgroundColor = .ypBackgroundDay
        
        HStackView.addArrangedSubview(VStackView)
        contentView.addSubview(HStackView)
        
        HStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            HStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            HStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            HStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            HStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
