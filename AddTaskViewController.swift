import UIKit

class AddTaskViewController: UIViewController, AddTaskViewInput {

    var presenter: AddTaskViewOutput!

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

        textView.isScrollEnabled = true
        return textView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)

        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)

        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16

        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Новая задача"

        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(detailsTextView)

        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 16
        stackView.addArrangedSubview(buttonStackView)

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ])

        detailsTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    @objc private func saveButtonTapped() {
        presenter.didTapSaveButton(title: titleTextField.text, details: detailsTextView.text)
    }

    @objc private func cancelButtonTapped() {
        presenter.didTapCancelButton()
    }

    func configure(with initialTitle: String?, initialDetails: String?) {
        titleTextField.text = initialTitle
        detailsTextView.text = initialDetails
    }

    func showSaveSuccessMessage() {
         print("Task saved successfully!")
    }

    func showSaveErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Ошибка сохранения", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

     func dismissView() {
         view.endEditing(true)
     }
}
