import UIKit

class ToDoViewController: UIViewController, ToDoViewInput {

    var presenter: ToDoViewOutput!
    private var tasks: [Task] = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ToDoTableViewCell.self, forCellReuseIdentifier: "ToDoCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemBackground
        table.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        return table
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск задач"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var themeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.tintColor = .secondaryLabel
        b.setImage(UIImage(systemName: ThemeManager.shared.current.iconName), for: .normal)
        b.showsMenuAsPrimaryAction = true
        b.menu = makeThemeMenu()
        return b
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var emptyView: UIStackView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        let container = UIStackView(arrangedSubviews: [stack])
        container.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTasks), name: .tasksDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidLoad()
    }

    @objc private func reloadTasks() {
        presenter.viewDidLoad()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Задачи"

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        setupTableHeader()

        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButtonTapped))
    }

    private func setupTableHeader() {
        let container = UIView()
        container.backgroundColor = .clear

        container.addSubview(themeButton)
        container.addSubview(searchBar)
        searchBar.delegate = self

        NSLayoutConstraint.activate([
            themeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            themeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            themeButton.widthAnchor.constraint(equalToConstant: 28),
            themeButton.heightAnchor.constraint(equalToConstant: 28),

            searchBar.leadingAnchor.constraint(equalTo: themeButton.trailingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            searchBar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])

        container.layoutIfNeeded()
        let height = searchBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 16
        container.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: max(56, height))
        tableView.tableHeaderView = container
    }

    private func makeThemeMenu() -> UIMenu {
        let actions = AppTheme.allCases.map { theme in
            UIAction(title: theme.title, image: UIImage(systemName: theme.iconName), state: ThemeManager.shared.current == theme ? .on : .off) { [weak self] _ in
                ThemeManager.shared.current = theme
                ThemeManager.shared.apply(to: (UIApplication.shared.delegate as? AppDelegate)?.window)
                self?.themeButton.setImage(UIImage(systemName: theme.iconName), for: .normal)
                self?.themeButton.menu = self?.makeThemeMenu()
            }
        }
        return UIMenu(title: "Тема", children: actions)
    }

    @objc private func addTaskButtonTapped() {
        presenter.didTapAddTask()
    }

    func displayTasks(_ tasks: [Task]) {
        self.tasks = tasks
        updateEmptyState()
        tableView.reloadData()
    }

    private func updateEmptyState() {
        if tasks.isEmpty {
            if tableView.backgroundView == nil {
                let wrapper = UIView(frame: tableView.bounds)
                wrapper.addSubview(emptyView)
                emptyView.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor).isActive = true
                emptyView.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor).isActive = true
                tableView.backgroundView = wrapper
            }
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        let task = tasks[indexPath.row]
        cell.configure(title: task.title, details: task.details, date: task.creationDate, isCompleted: task.isCompleted)
        cell.delegate = self
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

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasks[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu() }
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
                self.presenter.didSelectTask(task)
            }
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                var items: [Any] = []
                if let title = task.title { items.append(title) }
                if let details = task.details { items.append(details) }
                let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
                self.present(vc, animated: true)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.presenter.didSwipeToDelete(task)
            }
            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
}

extension ToDoViewController: ToDoTableViewCellDelegate {
    func todoCellDidToggleCompletion(_ cell: ToDoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            presenter.didTapToggleCompletion(for: tasks[indexPath.row])
        }
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
