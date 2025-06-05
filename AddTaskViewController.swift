import UIKit

// Импортируем протоколы из AddTaskProtocols.swift
// MARK: - Protocols are defined in AddTaskProtocols.swift

// MARK: - View Controller Class
class AddTaskViewController: UIViewController, AddTaskViewInput {

    // MARK: - Properties
    var presenter: AddTaskViewOutput! // Ссылка на Презентер

    // MARK: - UI Elements
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название задачи"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let detailsTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        // Включаем скроллинг, если текст не помещается
        textView.isScrollEnabled = true
        return textView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        // Убираем addTarget отсюда
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        // Убираем addTarget отсюда
        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        // Настройка отступов stackView от краев (для примера, лучше использовать Auto Layout)
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Настраиваем UI, включая добавление целей для кнопок
        presenter.viewDidLoad()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Новая задача" // Устанавливаем заголовок экрана

        // Добавляем элементы в stack view
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(detailsTextView)

        // Добавляем кнопки в отдельный stack view для горизонтального расположения (опционально)
        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually // Равномерно распределяем кнопки
        buttonStackView.spacing = 16
        stackView.addArrangedSubview(buttonStackView)


        // Добавляем stack view на View
        view.addSubview(stackView)

        // Настраиваем Auto Layout для stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0), // Используем margins stackView для верхнего отступа
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0), // Используем margins stackView для левого отступа
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0), // Используем margins stackView для правого отступа
            // stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20) // Опционально: ограничить снизу
        ])

        // Настраиваем высоту TextView (опционально, можно сделать динамической)
        detailsTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        // >>> Переносим добавление target/action сюда <<<
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }


    // MARK: - Actions

    @objc private func saveButtonTapped() {
        presenter.didTapSaveButton(title: titleTextField.text, details: detailsTextView.text)
    }

    @objc private func cancelButtonTapped() {
        presenter.didTapCancelButton()
    }

    // MARK: - AddTaskViewInput Methods

    func configure(with initialTitle: String?, initialDetails: String?) {
        titleTextField.text = initialTitle
        detailsTextView.text = initialDetails
    }

    func showSaveSuccessMessage() {
        // Optionally show a quick success message (e.g., using a HUD or temporary label)
         print("Task saved successfully!")
        // Для простоты можно проигнорировать это сообщение и просто закрыть экран
    }

    func showSaveErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Ошибка сохранения", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

     func dismissView() {
         // Этот метод вызывается Презентером, чтобы View Controller закрыл себя.
         // Фактическое закрытие (dismiss или pop) происходит в Router.
         // Здесь мы просто скрываем клавиатуру перед закрытием.
         view.endEditing(true)
          // Важно: View Controller сам себя не dismiss'ит, это делает Router
     }
}

// MARK: - Optional: Delegate methods for TextView (e.g., for placeholder)
// extension AddTaskViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == UIColor.lightGray {
//            textView.text = nil
//            textView.textColor = UIColor.black
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Описание задачи (опционально)"
//            textView.textColor = UIColor.lightGray
//        }
//    }
// }
