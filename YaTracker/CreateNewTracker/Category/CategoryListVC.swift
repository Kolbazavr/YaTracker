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

@MainActor
final class CategoryListVC: UIViewController {
    
    weak var delegate: CategoryListVCDelegate?
    
    private let viewModel: CategoryListViewModel
    private let headerTitle = UILabel()
    private let tableView = MenuTableView()
    
    private var emptyStateImageView = UIImageView(image: UIImage(resource: .emptyState))
    
    private lazy var addCategoryButton: UIButton = {
        let button = DoneButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        label.text = "Привычки и события можно\nобъединить по смыслу"
        return label
    }()

    init(selectedCategory: String? = nil, categoryStore: TrackerCategoryStoreProtocol, delegate: CategoryListVCDelegate? = nil) {
        self.viewModel = CategoryListViewModel(categoryStore: categoryStore, preselectedCategoryTitle: selectedCategory)
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupTableView()
        setupUI()
    }
        
    private func bindViewModel() {
        viewModel.categoriesDidChange = { [weak self] categories in
            self?.showEmptyStateStub(categories.isEmpty)
            self?.updateTableViewItems()
        }
        
        viewModel.selectedCategoryDidChange = { [weak self] title in
            self?.categoryTitleWasSelected(title)
        }
        
        viewModel.categoryToRenameDidChange = { [weak self] _ in
            self?.navigateToAddNewCategory()
        }
        
        viewModel.loadCategories()
    }
    
    private func setupTableView() {
        tableView.menuSelectionDelegate = self
        tableView.addMenuProvider { [weak self] IndexPath in
            guard let self else { return nil }
            let categoryTitle = self.viewModel.categories[IndexPath.row].title
            
            let edit = UIAction(title: "Редактировать") { [weak self] _ in
                self?.didChooseToEditCategory(categoryToEdit: categoryTitle)
            }
            let delete = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                self?.didChooseToDeleteCategory(categoryToDelete: categoryTitle)
            }
            return UIMenu(title: "", children: [edit, delete])
        }
    }
    
    private func didChooseToEditCategory(categoryToEdit: String?) {
        viewModel.categoryToRename = categoryToEdit
    }
    
    private func didChooseToDeleteCategory(categoryToDelete: String) {
        let alert = UIAlertController(title: "Эта категория точно не нужна?", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.delete(categoryWithTitle: categoryToDelete)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func updateTableViewItems() {
        let menuItems: [MenuItem] = viewModel.categories.map { .categorySelector(categoryTitle: $0.title, isSelected: $0.title == viewModel.selectedCategoryTitle) }
        tableView.addMenuItems(menuItems)
    }
    
    private func categoryTitleWasSelected(_ title: String?) {
        guard let title else { return }
        tableView.isUserInteractionEnabled = false
        updateTableViewItems()
        delegate?.didSelectCategory(categoryTitle: title)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func navigateToAddNewCategory() {
        let vc = AddNewCategoryVC(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showEmptyStateStub(_ show: Bool) {
        emptyStateLabel.isHidden = !show
        emptyStateImageView.isHidden = !show
    }
    
    @objc private func didTapAddCategoryButton() {
        didChooseToEditCategory(categoryToEdit: nil)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        let tapRecognizer: UITapGestureRecognizer = .init(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        headerTitle.text = "Категория"
        headerTitle.font = .systemFont(ofSize: 16, weight: .medium)
        headerTitle.textAlignment = .center
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerTitle)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addCategoryButton)
        
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateImageView)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerTitle.heightAnchor.constraint(equalToConstant: 79),
            
            tableView.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: 0),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.widthAnchor.constraint(equalToConstant: 343),
            emptyStateLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}

extension CategoryListVC: MenuTableViewDelegate {
    func didSelectMenuItem(_ menuItem: MenuItem, at cell: MenuCell?) {
        guard case let .categorySelector(categoryTitle, _) = menuItem else { return }
        viewModel.selectedCategoryTitle = categoryTitle
    }
}
