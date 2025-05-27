//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by George on 26/05/25.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistantContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    private init(){
        persistantContainer = NSPersistentContainer(name: "ToDoModel")
        persistantContainer.loadPersistentStores {(storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed; \(error)")
            }
        }
    }
    
    func saveCategory(name: String){
        let category = Category(context: CoreDataManager.shared.context)
        category.name = name
        saveContext()
    }
    
    func fetchCategories(completion: (([Category]) -> Void))  {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        if let result = try? CoreDataManager.shared.context.fetch(request){
            completion(result)
        }
    }
    
    func updateCategory(category: Category, newName: String) {
        category.name = newName
        saveContext()
    }
    
    func deleteCategory(category: Category) {
        context.delete(category)
        saveContext()
    }
    
    func saveTodo(title: String, category: Category) {
        let todo = ToDo(context: CoreDataManager.shared.context)
        todo.title = title
        todo.isCompleted = false
        todo.category = category
        saveContext()
    }
    
    func fetchTodos(category: Category, completion: ((Set<ToDo>) -> Void)){
        if let todoSet = category.todos as? Set<ToDo> {
            completion(todoSet)
        }
    }
    
    func updateTodo(todo: ToDo, newTitle: String) {
        todo.title = newTitle
        saveContext()
    }
    
    func deleteTodo(todo: ToDo) {
        context.delete(todo)
        saveContext()
    }
    
    func saveContext(){
        let context = persistantContainer.viewContext
        if context.hasChanges {
            do{
                try context.save()
            }catch{
                print("Error Saving context: \(error)")
            }
        }
    }
}
