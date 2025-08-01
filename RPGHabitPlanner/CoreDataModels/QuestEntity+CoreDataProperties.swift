//
//  QuestEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//
//

import Foundation
import CoreData

extension QuestEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuestEntity> {
        return NSFetchRequest<QuestEntity>(entityName: "QuestEntity")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var difficulty: Int16
    @NSManaged public var dueDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var info: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isMainQuest: Bool
    @NSManaged public var progress: Int16
    @NSManaged public var title: String?
    @NSManaged public var tasks: NSOrderedSet?
    @NSManaged public var repeatType: String
    @NSManaged public var repeatIntervalWeeks: Int16
}

extension QuestEntity: Identifiable {
    var taskList: [TaskEntity] {
        (tasks?.array as? [TaskEntity]) ?? []
    }
}
