//
//  TrackerRecordStore.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import Foundation
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
//    func saveRecord(for tracker: TrackerCoreData, on date: Date) {
//        let newRecord = TrackerRecordCoreData(context: context)
//        newRecord.completionDate = date
//        newRecord.trackerId = tracker.id
//        newRecord.tracker = tracker
//        try? context.save()
//    }
//    
//    func deleteRecord(for tracker: TrackerCoreData, on date: Date) {
//        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
//        request.predicate = NSPredicate(format: "(trackerId == %@) AND (completionDate == %@)", tracker.id! as CVarArg, date as CVarArg)
//        
//        if let recordsToDelete = try? context.fetch(request) {
//            recordsToDelete.forEach { context.delete($0) }
//            try? context.save()
//        }
//    }
    
    func getRecordsCount(for trackerId: UUID) -> Int {
        let request: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "TrackerRecordCoreData")
        request.resultType = .countResultType
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        let count = (try? context.count(for: request)) ?? 0
        return count
    }
    
    func toggleRecord(for trackerCD: TrackerCoreData, on date: Date) -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "(trackerId == %@) AND (completionDate == %@)", trackerCD.id! as CVarArg, date as CVarArg)
        
        if let existingRecord = try? context.fetch(request).first {
            context.delete(existingRecord)
            try? context.save()
            return false
        } else {
            let newRecord = TrackerRecordCoreData(context: context)
            newRecord.completionDate = date
            newRecord.trackerId = trackerCD.id
            newRecord.tracker = trackerCD
            try? context.save()
            return true
        }
    }
}
