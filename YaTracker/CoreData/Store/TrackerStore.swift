//
//  TrackerStore.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import Foundation
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
//    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
//        let categoryToInsert = fetchCategory(with: title) ?? {
//            let newCategory = TrackerCategoryCoreData(context: context)
//            newCategory.title = title
//            return newCategory
//        }()
//        
//        let trackerCoreData = TrackerCoreData(context: context)
//        trackerCoreData.id = tracker.id
//        trackerCoreData.name = tracker.name
//        trackerCoreData.colorHex = tracker.colorHex
//        trackerCoreData.emoji = tracker.emoji
//        trackerCoreData.schedule = try? JSONEncoder().encode(tracker.schedule)
//        trackerCoreData.isPinned = tracker.isPinned
//        
//        trackerCoreData.category = categoryToInsert
//        
//        //CoreData saveContext
//    }
    func addTracker(_ tracker: Tracker, to categoryToInsert: TrackerCategoryCoreData) {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = tracker.colorHex
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = try? JSONEncoder().encode(tracker.schedule)
        trackerCoreData.isPinned = tracker.isPinned
        
        trackerCoreData.category = categoryToInsert
        
        try? context.save()
        //CoreData saveContext
    }
    
    func deleteTracker(with id: UUID) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let trackerToDelete = try? context.fetch(request).first {
            context.delete(trackerToDelete)
            
            try? context.save()
            //CoreData saveContext
        }
    }
    
    func fetchTracker(with id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
    
//    func fetchCategory(with title: String) -> TrackerCategoryCoreData? {
//        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
//        request.predicate = NSPredicate(format: "title == %@", title)
//        return try? context.fetch(request).first
//    }
}
