//
//  TrackerStore.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import CoreData

final class TrackerStore: NSObject {
    
    var onChange: (([TrackerCategory]) -> Void)?
    
    private var selectedWeekDay: WeekDay? = nil
    private var selectedName: String? = nil
    private var selectedCompletionState: Bool? = nil
    private var selectedCompletionDate: Date? = nil
    
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
    
    func changeWeekDayFilter(for date: Date) {
        selectedWeekDay = WeekDay(from: date)
        selectedCompletionDate = date
        applyFiltersAndSearch()
    }
    
    func changeNameFilter(to name: String) {
        selectedName = name
        applyFiltersAndSearch()
    }
    
    func setCompletionStateForFilter(_ isCompleted: Bool?, for date: Date) {
        selectedCompletionState = isCompleted
        selectedCompletionDate = date
    }
    
    func addTracker(_ tracker: Tracker, to categoryWithTitle: String) {
        context.perform { [weak self] in
            guard let self else { return }
            
            let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "title == %@", categoryWithTitle)
            categoryRequest.fetchLimit = 1
            
            let categoryToInsert = try? self.context.fetch(categoryRequest).first ?? {
                let newCategory = TrackerCategoryCoreData(context: self.context)
                newCategory.title = categoryWithTitle
                return newCategory
            }()
            
            let trackerIdRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            trackerIdRequest.predicate = NSPredicate(format: "id = %@", tracker.id as CVarArg)
            trackerIdRequest.fetchLimit = 1
            
            let trackerToSave = try? self.context.fetch(trackerIdRequest).first ?? {
                print("new tracker")
                return TrackerCoreData(context: self.context)
            }()
            
            guard let trackerToSave else { return }
            
            trackerToSave.id = tracker.id
            trackerToSave.name = tracker.name
            trackerToSave.colorHex = tracker.colorHex
            trackerToSave.emoji = tracker.emoji
            trackerToSave.isPinned = tracker.isPinned
            trackerToSave.schedule = tracker.schedule.bitmask
            trackerToSave.category = categoryToInsert

            saveContext()
        }
    }
    
    func deleteTracker(withId id: UUID) {
        context.perform { [weak self] in
            guard let self else { return }
            
            let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            if let trackerToDelete = try? self.context.fetch(request).first {
                context.delete(trackerToDelete)
            }
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
    
    func isThereAnyTrackers(on date: Date) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "(schedule & %d) != 0", WeekDay(from: date).bitValue)
        request.fetchLimit = 1
        request.resultType = .managedObjectIDResultType
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    func categoryName(with trackerId: UUID?) -> String? {
        guard let trackerId else { return nil }
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", trackerId as CVarArg)
        return try? context.fetch(request).first?.category?.title
    }
    
    func isTrackerCompletedToday(_ trackerId: UUID, date: Date) -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND completionDate == %@", trackerId as CVarArg, date as CVarArg)
        request.fetchLimit = 1
        return (try? context.count(for: request)) ?? 0 > 0
    }
    
    private func fetchTrackers() -> [TrackerCategory] {
        guard let sections = trackersFRC.sections else { return [] }
        return sections.compactMap { section in
            guard let trackerCDs = section.objects as? [TrackerCoreData] else { return nil }
            return TrackerCategory(title: section.name, trackers: trackerCDs.compactMap { $0.toStruct() })
        }
    }
    
    private func applyFiltersAndSearch() {
        var predicates: [NSPredicate] = []
        
        if let selectedWeekDay {
            predicates.append(NSPredicate(format: "(schedule & %d) != 0", selectedWeekDay.bitValue))
        }
        
        if let selectedName, !selectedName.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", selectedName))
        }
        
        if let selectedCompletionState {
            let format = selectedCompletionState ? "SUBQUERY(records, $r, $r.completionDate == %@).@count > 0" : "SUBQUERY(records, $r, $r.completionDate == %@).@count == 0"
            predicates.append(NSPredicate(format: format, (selectedCompletionDate ?? Date().onlyDate) as CVarArg))
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
