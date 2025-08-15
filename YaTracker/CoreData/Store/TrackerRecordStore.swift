//
//  TrackerRecordStore.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import Foundation
import CoreData

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func toggleRecord(for tracker: Tracker, on date: Date) {
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "(trackerId == %@) AND (completionDate == %@)", tracker.id as CVarArg, date as CVarArg)
        
        if let existingRecord = try? context.fetch(request).first {
            context.delete(existingRecord)
        } else {
            let newRecord = TrackerRecordCoreData(context: context)
            newRecord.completionDate = date
            newRecord.trackerId = tracker.id
            newRecord.tracker = fetchTrackerCD(with: tracker.id)
        }
        saveContext()
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
