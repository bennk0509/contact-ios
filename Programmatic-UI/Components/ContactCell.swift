//
//  ContactCell.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-28.
//

import SwiftUI

class ContactCell: UITableViewCell{
    
    private let avatarContainer = UIView()
    private let avatarImageView = UIImageView()
    private let initialLabel = UILabel()
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        // Cấu hình container hình tròn
        avatarContainer.layer.cornerRadius = 20 // Bán kính = 1/2 chiều cao (40/2)
        avatarContainer.clipsToBounds = true
        
        // Cấu hình ảnh avatar
        avatarImageView.contentMode = .scaleAspectFill
        
        // Cấu hình chữ cái đầu (Initial)
        initialLabel.font = .systemFont(ofSize: 16, weight: .medium)
        initialLabel.textColor = .white
        initialLabel.textAlignment = .center
        
        // Cấu hình tên
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
    func configure(with model: ContactModel) {
        nameLabel.text = model.name
        
        if let image = model.avatar {
            // CÓ ẢNH: Hiện ảnh, ẩn chữ, nền xám nhẹ
            avatarImageView.image = image
            avatarImageView.isHidden = false
            initialLabel.isHidden = true
            avatarContainer.backgroundColor = .systemGray6
        } else {
            // KHÔNG CÓ ẢNH: Ẩn ảnh, hiện chữ, nền màu random
            avatarImageView.image = nil
            avatarImageView.isHidden = true
            initialLabel.isHidden = false
            initialLabel.text = model.initial
            avatarContainer.backgroundColor = model.color
        }
    }
}
