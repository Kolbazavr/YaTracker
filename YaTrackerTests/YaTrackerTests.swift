//
//  YaTrackerTests.swift
//  YaTrackerTests
//
//  Created by ANTON ZVERKOV on 15.09.2025.
//

import XCTest
import SnapshotTesting
@testable import YaTracker

final class YaTrackerTests: XCTestCase {
    func testTrackersVCLight() {
        let trackerStore = TrackerStoreMock()
        let recordStore = RecordStoreMock()
        let categoryStore = CategoryStoreMock()
        let vc = TrackersViewController(trackerStore: trackerStore, recordStore: recordStore, categoryStore: categoryStore)
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersVCDark() {
        let trackerStore = TrackerStoreMock()
        let recordStore = RecordStoreMock()
        let categoryStore = CategoryStoreMock()
        let vc = TrackersViewController(trackerStore: trackerStore, recordStore: recordStore, categoryStore: categoryStore)
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}

final class TrackerStoreMock: TrackerStoreProtocol {
    func setup(onChange action: @escaping ([YaTracker.TrackerCategory]) -> Void) { }
    
    func changeWeekDayFilter(for date: Date) { }
    
    func changeNameFilter(to name: String) { }
    
    func setCompletionStateForFilter(_ isCompleted: Bool?, for date: Date) { }
    
    func addTracker(_ tracker: YaTracker.Tracker, to categoryWithTitle: String) { }
    
    func deleteTracker(withId id: UUID) { }
    
    func getCompletedTrackersCount(for trackerId: UUID) -> Int { 0 }
    
    func checkTrackerNameExists(_ name: String) -> Bool { false }
    
    func isThereAnyTrackers(on date: Date) -> Bool { true }
    
    func categoryName(with trackerId: UUID?) -> String? { "" }
    
    func isTrackerCompletedToday(_ trackerId: UUID, date: Date) -> Bool { false }
}

final class RecordStoreMock: TrackerRecordStoreProtocol {
    func toggleRecord(for tracker: YaTracker.Tracker, on date: Date) { }
}

final class CategoryStoreMock: TrackerCategoryStoreProtocol {
    func setup(onChange action: @escaping ([YaTracker.TrackerCategory]) -> Void) { }
    
    func fetchCategories() -> [YaTracker.TrackerCategory] { [] }
    
    func checkCategoryNameExists(_ title: String) -> Bool { false }
    
    func renameCategory(with title: String, to newTitle: String) { }
    
    func createEmptyCategory(withName name: String) { }
    
    func deleteCategory(withName name: String) { }
}
