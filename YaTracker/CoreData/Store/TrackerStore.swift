//
//  TrackerStore.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    
    var onChange: (([TrackerCategory]) -> Void)?
    
    private var selectedWeekDay: WeekDay? = nil
    private var selectedName: String? = nil
    private let context: NSManagedObjectContext
    
    private lazy var trackersFRC: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        let todayWeekDayMask = WeekDay(from: Date()).bitValue
        fetchRequest.predicate = NSPredicate(format: "(schedule & %d) != 0", todayWeekDayMask)
        
        let frc: NSFetchedResultsController<TrackerCoreData> = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func changeWeekDayFilter(to weekday: WeekDay) {
        selectedWeekDay = weekday
        applyFiltersAndSearch()
    }
    
    func changeNameFilter(to name: String) {
        selectedName = name
        applyFiltersAndSearch()
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
            newTracker.schedule = tracker.schedule.bitmask
            newTracker.category = categoryToInsert
            
            saveContext()
        }
    }
    
    func getCompletedTrackersCount(for trackerId: UUID) -> Int {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        return (try? context.count(for: request)) ?? 0
    }
    
    func checkTrackerNameExists(_ name: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        request.fetchLimit = 1
        request.resultType = .managedObjectIDResultType
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    func isTrackerCompletedToday(_ trackerId: UUID, date: Date) -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND completionDate == %@", trackerId as CVarArg, date as CVarArg)
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    private func fetchTrackers() -> [TrackerCategory] {
        guard let trackersCD = trackersFRC.fetchedObjects else { return [] }
        let groupedTrackersCD = Dictionary(grouping: trackersCD) { $0.category?.title ?? "" }
        return groupedTrackersCD.map { TrackerCategory(title: $0, trackers: $1.compactMap { $0.toStruct() }) }.sorted()
    }
    
    private func applyFiltersAndSearch() {
        var predicates: [NSPredicate] = []
        
        if let selectedWeekDay {
            predicates.append(NSPredicate(format: "(schedule & %d) != 0", selectedWeekDay.bitValue))
        }
        
        if let selectedName, !selectedName.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", selectedName))
        }
        
        trackersFRC.fetchRequest.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        try? trackersFRC.performFetch()
        onChange?(fetchTrackers())
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?(fetchTrackers())
    }
}
