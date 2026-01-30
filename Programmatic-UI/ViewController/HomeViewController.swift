//
//  HomeViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-28.
//

import UIKit

class HomeViewController: UIViewController {

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CONTACT LIST", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "HOME PAGE"
        
        setupUI()
    }

    private func setupUI() {
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 250),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        startButton.addTarget(self, action: #selector(openContactList), for: .touchUpInside)
    }

    @objc private func openContactList() {
        let contactVC = ContactListViewController()
        navigationController?.pushViewController(contactVC, animated: true)
    }
}
