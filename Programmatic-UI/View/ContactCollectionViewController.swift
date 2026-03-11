//
//  ContactCollectionViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//

import UIKit


class ContactCollectionViewController: UIViewController {
    
    private let viewModel: ContactListViewModel
    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.scrollDirection = .vertical
        
        //SPACING BETWEEN ROW
        layout.minimumLineSpacing = 10
        
        //SPACING BETWEEN HORIZONTAL
        layout.minimumInteritemSpacing = 10
        
        //PADING OF WHOLE COLLECTION VIEW
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    init(viewModel: ContactListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        view.backgroundColor = .systemBackground
        setUpCollectionView()
        loadData()
        
    }
    
    private func setUpCollectionView(){
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ContactCollectionCell.self, forCellWithReuseIdentifier: ContactCollectionCell.identifier)
        
        collectionView.register(LoadingCollectionCell.self, forCellWithReuseIdentifier: LoadingCollectionCell.identifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData(){
        Task{
            try await viewModel.loadInitialData()
            collectionView.reloadData()
        }
    }
    
}


extension ContactCollectionViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.isLoading == .loading ? viewModel.contacts.count + 1 : viewModel.contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == viewModel.contacts.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCollectionCell.identifier, for: indexPath) as! LoadingCollectionCell
            cell.start()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionCell.identifier, for: indexPath) as! ContactCollectionCell
        let contact = viewModel.contacts[indexPath.item]
        cell.configure(with: contact)
        return cell
    }
    
}

extension ContactCollectionViewController: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 10
        let spacing: CGFloat = 10
        let numColumns: CGFloat = 4
        
        // get the collection width
        let totalContentWidth = collectionView.bounds.width - (padding * 2)
        
        if indexPath.item == viewModel.contacts.count {
            return CGSize(width: totalContentWidth, height: 60)
        }
        
        let numSpacings: CGFloat = numColumns - 1
        let itemWidth = floor((totalContentWidth - numSpacings * spacing) / numColumns)
        
        return CGSize(width: itemWidth, height: itemWidth + 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let threshold = viewModel.contacts.count - 4
        guard indexPath.item == threshold, viewModel.isLoading == .rest else { return }
        
        viewModel.setLoadingState(loadingState: .loading)
        let currentCount = viewModel.contacts.count
        
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [IndexPath(item: currentCount, section: 0)])
        }
        
        Task {
            do {
                let newItems = try await viewModel.loadNextPage()
                if !newItems.isEmpty {
                    let loadingPath = IndexPath(item: currentCount, section: 0)
                    let newPaths = (currentCount..<(currentCount + newItems.count)).map { IndexPath(item: $0, section: 0) }
                    
                    collectionView.performBatchUpdates({
                        collectionView.deleteItems(at: [loadingPath])
                        viewModel.appendContacts(newItems)
                        collectionView.insertItems(at: newPaths)
                    })
                }
            } catch {
                viewModel.resetLoadingState()
                print("Error: \(error)")
            }
        }
    }
}
