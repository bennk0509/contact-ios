//
//  ContactCell.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-28.
//

import SwiftUI

class ContactCell: UITableViewCell{
    
    static let identifier = "ContactCell"
    
    private var imageLoadingTask: Task<Void, Never>?
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 22
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI(){
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingTask?.cancel()
        imageLoadingTask = nil
        
        avatarImageView.image = nil
        nameLabel.text = nil
    }
    
    func configure(with model: ContactModel) {
        nameLabel.text = model.name
        let cacheId = model.id
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .systemGray3
        
        imageLoadingTask = Task {
            if let cached = await ImageCacheManager.shared.getCachedImage(for: cacheId) {
                self.avatarImageView.image = cached
                return
            }
            
            guard let data = model.avatarData else { return }
            if let decoded = UIImage(data: data) {
                await ImageCacheManager.shared.cacheImage(decoded, for: cacheId)
                
                if Task.isCancelled { return }
                self.avatarImageView.image = decoded
            }
        }
    }
}

