//
//  CategoryListVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 30.07.2025.
//

import UIKit

protocol CategoryListVCDelegate: AnyObject {
    func didSelectCategory(categoryTitle: String)
}

final class CategoryListVC: UIViewController {
    
    weak var delegate: CategoryListVCDelegate?
    
    private let headerTitle = UILabel()
    private let tableView = MenuTableView()
    private lazy var doneButton: UIButton = {
        let button = DoneButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    init(delegate: CategoryListVCDelegate? = nil) {
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
        let menuItem: MenuItem = .textField(placeholder: "Введите название категории", limit: 38)
        
        tableView.addMenuItems([menuItem])
        tableView.menuSelectionDelegate = self
    }
    
    @objc private func didTapDoneButton() {
        delegate?.didSelectCategory(categoryTitle: "DummyCategory")
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        let tapRecognizer: UITapGestureRecognizer = .init(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        headerTitle.text = "Новая категория"
        headerTitle.font = .systemFont(ofSize: 16, weight: .medium)
        headerTitle.textAlignment = .center
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerTitle)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
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

extension CategoryListVC: MenuTableViewDelegate {
    func didSelectMenuItem(_ menuItem: MenuItem, at cell: MenuCell?) {
        cell?.selectTextField()
    }
}
