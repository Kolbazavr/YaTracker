//
//  CategoryListViewModel.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 24.08.2025.
//

import Combine
import Foundation

class CategoryListViewModel {
    @Published var categories: [TrackerCategory] = []
    @Published var selectedCategoryTitle: String?
    @Published var warning: String? = nil
    @Published var categoryToRename: String? = nil
    @Published var newCategoryTitle: String? = nil
    
    let maxNameLength: Int = 30
    
    private var nameCheckingWorkItem: DispatchWorkItem?
    private let categoryStore: TrackerCategoryStore
    
    private enum WarningType {
        case nameLength(Int)
        case nameExists
        
        var message: String {
            return switch self {
            case .nameLength(let limit): "Ограничение \(limit) символов"
            case .nameExists: "Уже есть такая"
            }
        }
    }
    
    init(categoryStore: TrackerCategoryStore, preselectedCategoryTitle: String? = nil) {
        self.selectedCategoryTitle = preselectedCategoryTitle
        self.categoryStore = categoryStore
        categoryStore.onChange = { [weak self] categories in
            self?.categories = categories
        }
        self.categories = categoryStore.fetchCategories()
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
