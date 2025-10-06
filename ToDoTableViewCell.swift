import UIKit

protocol ToDoTableViewCellDelegate: AnyObject {
    func todoCellDidToggleCompletion(_ cell: ToDoTableViewCell)
}

final class ToDoTableViewCell: UITableViewCell {

    weak var delegate: ToDoTableViewCellDelegate?

    private let completeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.tintColor = .tertiaryLabel
        return b
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        l.font = .preferredFont(forTextStyle: .headline)
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 2
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .secondaryLabel
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .caption2)
        l.textColor = .tertiaryLabel
        return l
    }()

    private var isCompleted: Bool = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        contentView.addSubview(completeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            completeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 24),
            completeButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: completeButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        completeButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        updateIcon()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String?, details: String?, date: Date?, isCompleted: Bool) {
        self.isCompleted = isCompleted
        titleLabel.attributedText = styledTitle(title ?? "", completed: isCompleted)
        subtitleLabel.text = details
        if let d = date {
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yy"
            dateLabel.text = df.string(from: d)
        } else {
            dateLabel.text = nil
        }
        subtitleLabel.textColor = isCompleted ? .systemGray : .secondaryLabel
        dateLabel.textColor = isCompleted ? .systemGray3 : .tertiaryLabel
        updateIcon()
    }

    private func styledTitle(_ text: String, completed: Bool) -> NSAttributedString {
        if completed {
            return NSAttributedString(string: text, attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.systemGray
            ])
        } else {
            return NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor.label
            ])
        }
    }

    private func updateIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = isCompleted ? UIImage(systemName: "checkmark.circle.fill", withConfiguration: config) : UIImage(systemName: "circle", withConfiguration: config)
        completeButton.setImage(image, for: .normal)
        completeButton.tintColor = isCompleted ? .systemYellow : .tertiaryLabel
    }

    @objc private func toggleTapped() {
        delegate?.todoCellDidToggleCompletion(self)
    }
}
