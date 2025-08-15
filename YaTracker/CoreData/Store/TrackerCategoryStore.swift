//
//  TrackerCategoryStore.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
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
    
    func fetchCategories() -> [TrackerCategory] {
        guard let categories = categoriesFRC.fetchedObjects else { return [] }
        return categories.map { $0.toStruct() }
    }
    
    func fetchCategoriesTitles() -> [String] {
        let request = NSFetchRequest<NSDictionary>(entityName: "TrackerCategoryCoreData")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["title"]
        request.returnsDistinctResults = true
        
        let results = try? context.fetch(request)
        return results?.compactMap { $0["title"] as? String } ?? []
    }
    
    func checkCategoryNameExists(_ name: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        request.fetchLimit = 1
        request.resultType = .managedObjectIDResultType
        return (try? context.count(for: request)) ?? 0 > 0
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        //for categories view?
    }
}
