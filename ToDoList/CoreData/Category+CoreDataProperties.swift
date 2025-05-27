//
//  Category+CoreDataProperties.swift
//  ToDoList
//
//  Created by George on 26/05/25.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var todos: NSSet?

}

extension Category {

    @objc(addToDosObject:)
    @NSManaged public func addToToDos(_ value: ToDo)
    
    @objc(removeToDosObject:)
    @NSManaged public func removeFromToDos(_ value: ToDo)
    
    @objc(addToDos:)
    @NSManaged public func addToToDos(_ value: NSSet)
    
    @objc(removeFromToDos:)
    @NSManaged public func removeFromToDos(_ value: NSSet)
}
