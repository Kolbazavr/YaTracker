//
//  TrackerCategoryStore.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    
    private var onChange: (([TrackerCategory]) -> Void)?
    
    private let context: NSManagedObjectContext
    
    private lazy var categoriesFRC: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let frc: NSFetchedResultsController<TrackerCategoryCoreData> = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func setup(onChange action: @escaping ([TrackerCategory]) -> Void) {
        self.onChange = action
    }
    
    func fetchCategories() -> [TrackerCategory] {
        guard let categories = categoriesFRC.fetchedObjects else { return [] }
        return categories.map { $0.toStruct() }
    }
    
    func checkCategoryNameExists(_ title: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title ==[c] %@", title)
        request.fetchLimit = 1
        request.resultType = .managedObjectIDResultType
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    func renameCategory(with title: String, to newTitle: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title ==[c] %@", title)
        request.fetchLimit = 1
        
        if let categoryToRename = try? context.fetch(request).first {
            categoryToRename.title = newTitle
            saveContext()
        }
    }
    
    func createEmptyCategory(withName name: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.title = name
        category.trackers = []
        saveContext()
    }
    
    func deleteCategory(withName name: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title ==[c] %@", name)
        request.fetchLimit = 1
        
        if let categoryToDelete = try? context.fetch(request).first {
            context.delete(categoryToDelete)
        }
    }
    
    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Saving context failed with error \(error)")
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onChange?(fetchCategories())
    }
}
