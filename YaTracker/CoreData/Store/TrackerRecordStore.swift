//
//  TrackerRecordStore.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 12.08.2025.
//

import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func toggleRecord(for tracker: Tracker, on date: Date)
}

final class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func toggleRecord(for tracker: Tracker, on date: Date) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "(trackerId == %@) AND (completionDate == %@)", tracker.id as CVarArg, date as CVarArg)
        request.fetchLimit = 1
        
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
    
    func findStatisticsData() -> (perfectDays: [Date], bestPeriod: Int, average: Int) {
        let weekDaysCounts = getTrackerCountsByWeekday()
        let recordsCountsByDay = getRecordsCountByDate()
        
        var perfectDays: [Date] = []
        
        for (date, recordCount) in recordsCountsByDay {
            let weekday = Calendar.current.component(.weekday, from: date)
            if recordCount == weekDaysCounts[weekday] {
                perfectDays.append(date)
            }
        }
        
        let bestPeriod = findBestPeriod()
        let averageTrackersPerDay: Int = recordsCountsByDay.count == 0 ? 0 : recordsCountsByDay.values.reduce(0, +) / recordsCountsByDay.count
        
        return (perfectDays, bestPeriod, averageTrackersPerDay)
    }
    
    func getTrackerCountsByWeekday() -> [Int: Int] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        var weekDaysCount: [Int: Int] = [:]
        
        for weekDay in 1...7 {
            weekDaysCount[weekDay] = 0
        }
        
        do {
            let trackers = try context.fetch(fetchRequest)
            for tracker in trackers {
                let schedule = tracker.schedule.weekDays
                for weekday in schedule {
                    weekDaysCount[weekday.rawValue]? += 1
                }
                
            }
        } catch {
            print("Error fetching trackers: \(error)")
        }
        return weekDaysCount
    }
    
    func allRecordsCount() -> Int {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        return (try? context.count(for: request)) ?? 0
    }
    
    private func fetchTrackerCD(with id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    private func findMaxRecordsCountForSameDate() -> Int {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "TrackerRecordCoreData")
        
        let expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "completionDate")])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "count"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        
        fetchRequest.propertiesToGroupBy = ["completionDate"]
        fetchRequest.propertiesToFetch = ["completionDate", expressionDescription]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let results = try context.fetch(fetchRequest) as? [[String: Any]] ?? []
            let maxCount = results.compactMap { $0["count"] as? Int }.max() ?? 0
            
            return maxCount
        } catch {
            print("Error fetching max count: \(error)")
            return 0
        }
    }
    
    private func getRecordsCountByDate() -> [Date: Int] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        var recordsCountByDate: [Date: Int] = [:]
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                guard let date = record.completionDate else { continue }
                recordsCountByDate[date, default: 0] += 1
            }
        } catch {
            print("Error fetching records: \(error)")
        }
        return recordsCountByDate
    }
    
    private func findBestPeriod() -> Int {
        let weekdayTrackerCounts = getTrackerCountsByWeekday()
        let recordsCountByDate = getRecordsCountByDate()
        
        var dateStatuses: [ ( date: Date, isPerfect: Bool ) ] = []
        
        for (date, recordCount) in recordsCountByDate {
            let weekDay = Calendar.current.component(.weekday, from: date)
            let isPerfect = recordCount == weekdayTrackerCounts[weekDay]
            dateStatuses.append((date, isPerfect))
        }
        
        dateStatuses.sort { $0.date < $1.date }
        
        var longestStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for (date, isPerfect) in dateStatuses {
            if isPerfect {
                if let prevDate = previousDate,
                   let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: prevDate),
                   Calendar.current.isDate(nextDay, inSameDayAs: date)
                {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
                longestStreak = max(longestStreak, currentStreak)
                previousDate = date
            } else {
                currentStreak = 0
                previousDate = nil
            }
        }
        return longestStreak
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
