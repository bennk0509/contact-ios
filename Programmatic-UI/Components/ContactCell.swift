//
//  ContactCell.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-28.
//

import SwiftUI

class ContactCell: UITableViewCell{
    
    static let identifier = "ContactCell"
        
    private let avatarContainer = UIView()
    private let avatarImageView = UIImageView()
    private let initialLabel = UILabel()
    private let nameLabel = UILabel()
    
    private var downloadTask: Task<Void, Never>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        avatarImageView.image = nil
        initialLabel.text = nil
    }
    
    private func setupUI() {
        avatarContainer.layer.cornerRadius = 20
        avatarContainer.clipsToBounds = true
        
        avatarImageView.contentMode = .scaleAspectFill
        
        initialLabel.font = .systemFont(ofSize: 16, weight: .medium)
        initialLabel.textColor = .white
        initialLabel.textAlignment = .center
        
        nameLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
        // Add Subviews
        contentView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(initialLabel)
        contentView.addSubview(nameLabel)
        
        // Auto Layout
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Avatar Container (Cố định 40x40)
            avatarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 40),
            avatarContainer.heightAnchor.constraint(equalToConstant: 40),
            
            // Image View (Tràn đầy container)
            avatarImageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            
            // Initial Label (Nằm chính giữa container)
            initialLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // 2. Hàm đổ dữ liệu từ Model vào Cell
    func configure(with model: ContactModel, imageProvider: @escaping (String) async -> Data?) {
        nameLabel.text = model.name
        initialLabel.text = model.initial
        
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemRed, .systemTeal, .systemPink]
        avatarContainer.backgroundColor = colors[model.colorIndex % colors.count]
        
        if model.hasAvatar {
            avatarImageView.isHidden = false
            initialLabel.isHidden = true
            downloadTask = Task {
                if let data = await imageProvider(model.id), !Task.isCancelled {
                    self.avatarImageView.image = UIImage(data: data)
                    self.initialLabel.isHidden = true
                } else {
                    self.avatarImageView.isHidden = true
                    self.initialLabel.isHidden = false
                }
            }
        } else {
            avatarImageView.isHidden = true
            initialLabel.isHidden = false
            avatarImageView.image = nil
        }
    }
}
