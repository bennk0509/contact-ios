//
//  LoadingCell.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//

import UIKit

final class LoadingCell: UITableViewCell {
    static let identifier = "LoadingCell"
    
    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func start() {
        spinner.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        spinner.startAnimating()
    }
}
