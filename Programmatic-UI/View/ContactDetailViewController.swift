//
//  ContactDetailViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    private let contact: ContactModel
    private let suggestedContacts: [ContactModel]
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    init(contact: ContactModel, suggested: [ContactModel]) {
        self.contact = contact
        self.suggestedContacts = suggested
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        setUpCollectionView()
    }
    
    private func setUpCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        
        collectionView.register(ContactDetailHeaderCell.self, forCellWithReuseIdentifier: ContactDetailHeaderCell.identifier)
        collectionView.register(ContactCollectionCell.self, forCellWithReuseIdentifier: ContactCollectionCell.identifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200)), subitems: [item])
                return NSCollectionLayoutSection(group: group)
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(100), heightDimension: .absolute(130)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 15
                section.contentInsets = .init(top: 10, leading: 16, bottom: 20, trailing: 16)
//                let header = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40)),
//                    elementKind: UICollectionView.elementKindSectionHeader,
//                    alignment: .top)
//                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }
}

extension ContactDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : suggestedContacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactDetailHeaderCell.identifier, for: indexPath) as! ContactDetailHeaderCell
            cell.configure(with: contact)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionCell.identifier, for: indexPath) as! ContactCollectionCell
            cell.configure(with: suggestedContacts[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
        header.configure(with: "Suggested for You")
        return header
    }
}
