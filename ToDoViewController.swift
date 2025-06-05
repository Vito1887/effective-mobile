import UIKit

// Импортируем протоколы из ToDoProtocols.swift
// MARK: - Protocols are defined in ToDoProtocols.swift

// MARK: - View Controller Class
class ToDoViewController: UIViewController, ToDoViewInput {

    // MARK: - Properties
    var presenter: ToDoViewOutput! // Ссылка на Презентер
    private var tasks: [Task] = [] // Данные для таблицы

    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ToDoCell") // Замените на вашу кастомную ячейку позже
        table.translatesAutoresizingMaskIntoConstraints = false // <-- Важно для Auto Layout
        table.backgroundColor = .yellow // <-- Добавьте цвет фона для отладки
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
        indicator.translatesAutoresizingMaskIntoConstraints = false // <-- Важно для Auto Layout
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Настраиваем UI, включая добавление целей для кнопок
        presenter.viewDidLoad() // Сообщаем Презентеру, что View загружена
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Задачи" // Устанавливаем заголовок экрана

        // Настраиваем Search Bar
        navigationItem.titleView = searchBar
        searchBar.delegate = self

        // Настраиваем Table View
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        // Удалите tableView.frame = view.bounds // <-- УДАЛИТЕ ЭТУ СТРОКУ


        // >>> ИСПОЛЬЗУЕМ AUTO LAYOUT CONSTRAINTS ДЛЯ tableView <<<
        NSLayoutConstraint.activate([
            // Привязываем верх таблицы к верхней границе Safe Area (под Navigation Bar)
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) // Привязываем низ к Safe Area
        ])


        // Настраиваем Activity Indicator (убедитесь, что эти constraints на месте)
        view.addSubview(activityIndicator)
         NSLayoutConstraint.activate([
              activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
          ])


        // Добавляем кнопку добавления задачи в Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButtonTapped))
    }

    // MARK: - Actions

    @objc private func addTaskButtonTapped() {
        presenter.didTapAddTask() // Сообщаем Презентеру о нажатии кнопки "Добавить"
    }

    // MARK: - ToDoViewInput Methods (реализуем методы протокола для обновления UI)

    func displayTasks(_ tasks: [Task]) {
        print("displayTasks called with \(tasks.count) tasks") // <-- Добавьте этот принт
        self.tasks = tasks
        tableView.reloadData() // Обновляем таблицу
        // После обновления данных и перезагрузки таблицы, скрываем индикатор загрузки
        // Презентер должен вызывать hideLoadingIndicator после успешной загрузки
        // hideLoadingIndicator() // Презентер должен вызывать этот метод
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
         // Опционально: скрыть таблицу или сделать ее полупрозрачной во время загрузки
         tableView.alpha = 0.5
         tableView.isUserInteractionEnabled = false
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
         // Возвращаем таблицу в нормальное состояние
         tableView.alpha = 1.0
         tableView.isUserInteractionEnabled = true
    }


    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // TODO: Implement other ViewInput methods for search UI state, etc.
}

// MARK: - UITableViewDataSource
extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title // Отображаем название задачи

         // Пример простого отображения статуса выполнения (можно улучшить)
         if task.isCompleted {
             cell.accessoryType = .checkmark
         } else {
             cell.accessoryType = .none
         }

        return cell
    }

     // Реализация свайпа для удаления
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             let taskToDelete = tasks[indexPath.row]
             presenter.didSwipeToDelete(taskToDelete) // Сообщаем презентеру об удалении
             // Удаление из локального массива и обновление таблицы произойдет после ответа от презентера/интерактора
         }
     }
}

// MARK: - UITableViewDelegate
extension ToDoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTask = tasks[indexPath.row]
        presenter.didSelectTask(selectedTask) // Сообщаем Презентеру о выборе задачи
    }

     // Пример обработки тапа по ячейке для переключения статуса (можно добавить отдельный чекбокс)
      func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
          let taskToToggle = tasks[indexPath.row]
          presenter.didTapToggleCompletion(for: taskToToggle) // Сообщаем презентеру о переключении статуса
      }
}

// MARK: - UISearchBarDelegate
extension ToDoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.didSearch(with: searchText) // Сообщаем Презентеру об изменении текста поиска
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter.didSearch(with: "") // При отмене поиска, сбрасываем его
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder() // Скрываем клавиатуру после нажатия "Поиск"
    }
}
