//
//  DataProvider.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import UIKit
import CoreData

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdate()
}

final class DataProvider: NSObject {
    private let context: NSManagedObjectContext
    
    weak var delegate: TrackerDataProviderDelegate?
    
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        
        let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }
    
    func fetchCategories() -> [TrackerCategory] {
        guard let categories = fetchResultsController.fetchedObjects else { return [] }
        return categories.map { $0.toStruct() }
    }
    
    func addTracker(_ tracker: Tracker, to categoryWithTitle: String) {
        context.perform { [weak self] in
            guard let self else { return }
            
            let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "title == %@", categoryWithTitle)
            
            let categoryToInsert = try? self.context.fetch(categoryRequest).first ?? {
                let newCategory = TrackerCategoryCoreData(context: self.context)
                newCategory.title = categoryWithTitle
                return newCategory
            }()
            
            let newTracker: TrackerCoreData = TrackerCoreData(context: self.context)
            newTracker.id = tracker.id
            newTracker.name = tracker.name
            newTracker.colorHex = tracker.colorHex
            newTracker.emoji = tracker.emoji
            newTracker.isPinned = tracker.isPinned
            newTracker.schedule = try? JSONEncoder().encode(tracker.schedule)
            newTracker.category = categoryToInsert
            
            saveContext()
        }
    }
    
    func toggleRecord(for trackerId: UUID, on date: Date) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "(trackerId == %@) AND (completionDate == %@)", trackerId as CVarArg, date as CVarArg)
        
        if let existingRecord = try? context.fetch(request).first {
            context.delete(existingRecord)
        } else {
            let newRecord = TrackerRecordCoreData(context: context)
            newRecord.completionDate = date
            newRecord.trackerId = trackerId
            newRecord.tracker = fetchTrackerCD(with: trackerId)
        }
        saveContext()
    }
    
    func getCompletedTrackersCount(for trackerId: UUID) -> Int {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        return (try? context.count(for: request)) ?? 0
    }
    
    func isTrackerCompletedToday(_ trackerId: UUID, date: Date) -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND completionDate == %@", trackerId as CVarArg, date as CVarArg)
        
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    func clearAllCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let entityNames = appDelegate.persistentContainer.managedObjectModel.entities.compactMap { $0.name }
        
        entityNames.forEach { entityName in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Error deleting \(entityName): \(error)")
            }
        }
        context.refreshAllObjects()
    }
    
    private func fetchTrackerCD(with id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
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

extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
