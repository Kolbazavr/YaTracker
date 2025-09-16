//
//  CategoryListViewModel.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 24.08.2025.
//


import Foundation

@MainActor
final class CategoryListViewModel {
    var categories: [TrackerCategory] = [] { didSet { categoriesDidChange?(categories) } }
    var selectedCategoryTitle: String? { didSet { selectedCategoryDidChange?(selectedCategoryTitle) } }
    var warning: String? = nil { didSet { warningDidChange?(warning) } }
    var categoryToRename: String? = nil { didSet { categoryToRenameDidChange?(categoryToRename) } }
    var newCategoryTitle: String? = nil { didSet { newCategoryTitleDidChange?(newCategoryTitle) } }
    
    var categoriesDidChange: (([TrackerCategory]) -> Void)?
    var selectedCategoryDidChange: ((String?) -> Void)?
    var warningDidChange: ((String?) -> Void)?
    var categoryToRenameDidChange: ((String?) -> Void)?
    var newCategoryTitleDidChange: ((String?) -> Void)?
    
    let maxNameLength: Int = 30
    
    private var nameCheckingWorkItem: DispatchWorkItem?
    private let categoryStore: TrackerCategoryStoreProtocol
    
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
    
    init(categoryStore: TrackerCategoryStoreProtocol, preselectedCategoryTitle: String? = nil) {
        self.selectedCategoryTitle = preselectedCategoryTitle
        self.categoryStore = categoryStore
        categoryStore.setup { [weak self] categories in
            self?.categories = categories
        }
    }
    
    func loadCategories() {
        categories = categoryStore.fetchCategories()
    }
    
    func processCategory() {
        nameCheckingWorkItem?.perform()
        guard let newCategoryTitle, !newCategoryTitle.isEmpty else { return }
        if let categoryToRename {
            categoryStore.renameCategory(with: categoryToRename, to: newCategoryTitle)
        } else {
            categoryStore.createEmptyCategory(withName: newCategoryTitle)
        }
        selectedCategoryTitle = newCategoryTitle
    }
    
    func delete(categoryWithTitle: String) {
        categoryStore.deleteCategory(withName: categoryWithTitle)
    }
    
    func checkCategoryName(_ name: String, isOverLimit: Bool) {
        nameCheckingWorkItem?.cancel()
        
        let newWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let nameIsAllowed = isOverLimit ? false : !categoryStore.checkCategoryNameExists(trimmedName)
            newCategoryTitle = nameIsAllowed ? trimmedName : nil
            
            guard (isOverLimit || !nameIsAllowed) != (self.warning != nil) else { return }
            let warningText = isOverLimit ? WarningType.nameLength(maxNameLength).message : WarningType.nameExists.message
            warning = isOverLimit || !nameIsAllowed ? warningText : nil
        }
        nameCheckingWorkItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: newWorkItem)
    }
}
