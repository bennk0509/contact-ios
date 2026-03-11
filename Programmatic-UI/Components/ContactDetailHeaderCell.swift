//
//  ContactDetailHeaderCell.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//
import UIKit

class ContactDetailHeaderCell: UICollectionViewCell {
    static let identifier = "ContactDetailHeaderCell"
    
    private var imageLoadingTask: Task<Void, Never>?
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingTask?.cancel()
        imageLoadingTask = nil
        avatarImageView.image = nil
        nameLabel.text = nil
    }
    
    func configure(with contact: ContactModel) {
        nameLabel.text = contact.name
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .systemGray3
        
        imageLoadingTask = Task {
            await bindingImage(model: contact)
        }
    }
    
    private func bindingImage(model: ContactModel) async {
        let cacheId = model.id
        if let cached = await ImageCacheManager.shared.getCachedImage(for: cacheId) {
            self.avatarImageView.image = cached
            return
        }
        
        guard let data = model.avatarData else { return }
        
        if let decoded = UIImage(data: data) {
            await ImageCacheManager.shared.cacheImage(decoded, for: cacheId)
            if Task.isCancelled { return }
            self.avatarImageView.image = decoded
            self.avatarImageView.layer.cornerRadius = 35
        }
    }
}
