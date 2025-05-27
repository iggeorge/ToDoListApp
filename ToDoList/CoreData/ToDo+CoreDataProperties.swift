//
//  ToDo+CoreDataProperties.swift
//  ToDoList
//
//  Created by George on 26/05/25.
//
//

import Foundation
import CoreData


extension ToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDo> {
        return NSFetchRequest<ToDo>(entityName: "ToDo")
    }

    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var category: Category?


}
