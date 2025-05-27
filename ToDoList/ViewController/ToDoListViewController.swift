//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by George on 26/05/25.
//

import Foundation
import CoreData
import UIKit

class ToDoListViewController: UIViewController {
    
    private var tableView: UITableView!
    private var noDataLabel: UILabel!
    private let category: Category
    private var todos: [ToDo]  = []
    
    
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = category.name
        
        setupAddButton()
        setupTableView()
        fetchTodos()
    }
    
    private func setupTableView(){
        
        // tableView
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ToDoCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        
        noDataLabel = UILabel()
        noDataLabel.text = "Todo is Empty"
        noDataLabel.textAlignment = .center
        noDataLabel.textColor = .gray
        noDataLabel.isHidden = true
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)

        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupAddButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:  .add, target: self, action: #selector(addTodo))
    }
    
    @objc private func addTodo(){
        let alert = UIAlertController(title: "New To-Do", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            CoreDataManager.shared.saveTodo(title: title, category: self.category)
            self.fetchTodos()
        }))
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    private func fetchTodos(){
        CoreDataManager.shared.fetchTodos(category: category) { [weak self] result in
            self?.todos = Array(result)
            let isEmpty = result.isEmpty
            DispatchQueue.main.async {
                self?.noDataLabel.isHidden = !isEmpty
                self?.tableView.isHidden = isEmpty
                self?.tableView.reloadData()
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        
        let checkbox = todo.isCompleted ? "☑️" : "⬜️"
        config.text = "\(checkbox) \(todo.title ?? "")"
        
        if todo.isCompleted {
            let attributed = NSAttributedString(string: "\(checkbox) \(todo.title ?? "")", attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.gray
            ])
            config.attributedText = attributed
        }
        
        config.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = todos[indexPath.row]
        todo.isCompleted.toggle()
        CoreDataManager.shared.saveContext()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let todo = todos[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
            CoreDataManager.shared.deleteTodo(todo: todo)
            self.fetchTodos()
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, completionHandler in
            let alert = UIAlertController(title: "Edit To-Do", message: "Update the task", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = todo.title
            }
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
                CoreDataManager.shared.updateTodo(todo: todo, newTitle: newTitle)
                self.fetchTodos()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemGray
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}


