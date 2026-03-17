//
//  ContactCollectionCell.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//

import UIKit

final class ContactCollectionCell: UICollectionViewCell {
    static let identifier: String = "ContactCollectionCell"

    private var imageLoadingTask: Task<Void, Never>?

    private let avatarContainer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let initialLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.backgroundColor = .systemBackground

        avatarContainer.addSubview(initialLabel)
        avatarContainer.addSubview(avatarImageView)

        contentView.addSubview(avatarContainer)
        contentView.addSubview(nameLabel)
        contentView.addSubview(chevron)
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            // Avatar container
            avatarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 44),
            avatarContainer.heightAnchor.constraint(equalToConstant: 44),

            // Initial label inside avatar
            initialLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            // Avatar image fills container
            avatarImageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),

            // Chevron
            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 8),
            chevron.heightAnchor.constraint(equalToConstant: 13),

            // Name label
            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // Separator at bottom
            separator.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingTask?.cancel()
        imageLoadingTask = nil
        avatarImageView.image = nil
        avatarImageView.isHidden = true
        nameLabel.text = nil
        initialLabel.text = nil
    }

    func configure(with model: ContactModel) {
        nameLabel.text = model.name
        initialLabel.text = model.initial

        let colors: [UIColor] = [.systemBlue, .systemIndigo, .systemPurple, .systemPink,
                                 .systemRed, .systemOrange, .systemGreen, .systemTeal]
        avatarContainer.backgroundColor = colors[model.colorIndex % colors.count]

        imageLoadingTask = Task {
            await bindingImage(model: model)
        }
    }

    private func bindingImage(model: ContactModel) async {
        let cacheId = model.id
        if let cached = await ImageCacheManager.shared.getCachedImage(for: cacheId) {
            avatarImageView.image = cached
            avatarImageView.isHidden = false
            return
        }

        guard let data = model.avatarData else { return }

        if let decoded = UIImage(data: data) {
            await ImageCacheManager.shared.cacheImage(decoded, for: cacheId)
            if Task.isCancelled { return }
            avatarImageView.image = decoded
            avatarImageView.isHidden = false
        }
    }
}
