//
//  AddNewCategoryVC.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 24.08.2025.
//

import UIKit
import Combine

final class AddNewCategoryVC: UIViewController  {
    
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: CategoryListViewModel
    private let headerTitle = UILabel()
    private let tableView = MenuTableView()
    
    private lazy var doneButton: UIButton = {
        let button = DoneButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupTableViewItems()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancellables.removeAll()
    }
    
    private func bindViewModel() {
        viewModel.$newCategoryTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCategoryTitle in
                self?.doneButton.isEnabled = !(newCategoryTitle?.isEmpty ?? true)
            }
            .store(in: &cancellables)
        
        viewModel.$warning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] warningText in
                self?.showWarning(with: warningText)
            }
            .store(in: &cancellables)
    }
    
    private func setupTableViewItems() {
        let menuItem: MenuItem = .textField(placeholder: "Введите название категории", limit: viewModel.maxNameLength, text: viewModel.categoryToRename)
        tableView.addMenuItems([menuItem])
        tableView.menuTextFieldDelegate = self
        tableView.menuSelectionDelegate = self
    }
    
    private func showWarning(with warningText: String?) {
        tableView.showWarningFooter(with: warningText ?? "", show: warningText != nil)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func didTapDoneButton() {
        navigationController?.popViewController(animated: true)
        viewModel.processCategory()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        let tapRecognizer: UITapGestureRecognizer = .init(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        headerTitle.text = viewModel.categoryToRename == nil ? "Новая категория" : "Редактирование категории"
        headerTitle.font = .systemFont(ofSize: 16, weight: .medium)
        headerTitle.textAlignment = .center
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerTitle)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerTitle.heightAnchor.constraint(equalToConstant: 79),
            
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

extension AddNewCategoryVC: MenuTextFieldDelegate {
    func checkTrackerName(_ name: String, isOverLimit: Bool) {
        viewModel.checkCategoryName(name, isOverLimit: isOverLimit)
    }
}

extension AddNewCategoryVC: MenuTableViewDelegate {
    func didSelectMenuItem(_ menuItem: MenuItem, at cell: MenuCell?) {
        cell?.selectTextField()
    }
}
