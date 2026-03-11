//
//  ContactCollectionCell.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//

import SwiftUI

final class ContactCollectionCell: UICollectionViewCell{
    static let identifier: String = "ContactCollectionCell"
    
    private var imageLoadingTask: Task<Void, Never>?
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
//        iv.backgroundColor = .systemGray5
        
        iv.layer.cornerRadius = 35
        
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
        
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI(){
//        contentView.backgroundColor = .secondarySystemBackground
//        contentView.layer.cornerRadius = 15
//        contentView.clipsToBounds = true
//        
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.1
//        layer.shadowOffset = CGSize(width: 0, height: 4)
//        layer.shadowRadius = 6
//        layer.masksToBounds = false
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
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
    
    func configure(with model: ContactModel) {
        nameLabel.text = model.name
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .systemGray3
        
        imageLoadingTask = Task {
            await bindingImage(model: model)
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
