import UIKit

class ToDoViewController: UIViewController, ToDoViewInput {

    var presenter: ToDoViewOutput!
    private var tasks: [Task] = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ToDoCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .yellow
        return table
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск задач"
        return searchBar
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ToDoViewController: viewDidLoad called")
        setupUI()
        print("ToDoViewController: setupUI completed. TableView frame: \(tableView.frame)")
        print("ToDoViewController: TableView background color: \(tableView.backgroundColor ?? .clear)")
        presenter.viewDidLoad()
    }

    private func setupUI() {
        print("ToDoViewController: setupUI called")
        view.backgroundColor = .systemBackground
        title = "Задачи"

        navigationItem.titleView = searchBar
        searchBar.delegate = self

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        view.addSubview(activityIndicator)
         NSLayoutConstraint.activate([
              activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
          ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButtonTapped))
        print("ToDoViewController: TableView constraints activated")
    }

    @objc private func addTaskButtonTapped() {
        presenter.didTapAddTask()
    }

    func displayTasks(_ tasks: [Task]) {
        print("displayTasks called with \(tasks.count) tasks")
        self.tasks = tasks
        tableView.reloadData()
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
         tableView.alpha = 0.5
         tableView.isUserInteractionEnabled = false
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
         tableView.alpha = 1.0
         tableView.isUserInteractionEnabled = true
    }


    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title

         if task.isCompleted {
             cell.accessoryType = .checkmark
         } else {
             cell.accessoryType = .none
         }

        return cell
    }

     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             let taskToDelete = tasks[indexPath.row]
             presenter.didSwipeToDelete(taskToDelete)
         }
     }
}

extension ToDoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTask = tasks[indexPath.row]
        presenter.didSelectTask(selectedTask)
    }

      func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
          let taskToToggle = tasks[indexPath.row]
          presenter.didTapToggleCompletion(for: taskToToggle)
      }
}

extension ToDoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.didSearch(with: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter.didSearch(with: "")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
    }
}
