//
//  ViewController.swift
//  ToDoList
//
//  Created by George on 26/05/25.
//

import UIKit
import CoreData

class CategoryListViewController: UIViewController  {
    
    private var tableView: UITableView!
    private var noDataLabel: UILabel!
    private var categories: [Category] = []
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        title = "To-Do List"
        setupAddButton()
        setupSubviews()
        fetchCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }
    
    private func setupSubviews(){

        // tableView
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        // noDataLabel
        noDataLabel = UILabel()
        noDataLabel.text = "Category is Empty"
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategory))
    }
    
    @objc private func addCategory(){
        let alert = UIAlertController(title: "New Category", message: "Enter Category Name", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            CoreDataManager.shared.saveCategory(name: name)
            self.fetchCategories()
        }))
        present(alert, animated: true)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    private func fetchCategories(){
        CoreDataManager.shared.fetchCategories { [weak self] result in
            self?.categories = result
            let isEmpty = result.isEmpty
            DispatchQueue.main.async {
                self?.noDataLabel.isHidden = !isEmpty
                self?.tableView.isHidden = isEmpty
                self?.tableView.reloadData()
            }
        }
    }
    
    private func countOfCategory(category: Category) -> Int {
        // Get task count for this category
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "category == %@", category),
            NSPredicate(format: "isCompleted == %@", NSNumber(value: false))
        ])
        do {
            let count = try context.count(for: request)
            return count
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Get task count for this category
        let taskCount = countOfCategory(category: category)
        
        // Configure cell text
        var config = cell.defaultContentConfiguration()
        config.text = "\(category.name ?? "No Name") (\(taskCount))"
        config.textProperties.font = .systemFont(ofSize: 17, weight: .medium)
        config.textProperties.color = .label
        
        cell.contentConfiguration = config
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ToDoListViewController(category: categories[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let category = categories[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            CoreDataManager.shared.deleteCategory(category: category)
            self.fetchCategories()
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            let alert = UIAlertController(title: "Edit Category", message: "Update the name", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = category.name
            }
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                guard let newName = alert.textFields?.first?.text, !newName.isEmpty else { return }
                CoreDataManager.shared.updateCategory(category: category, newName: newName)
                self.fetchCategories()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemGray
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
    
}


