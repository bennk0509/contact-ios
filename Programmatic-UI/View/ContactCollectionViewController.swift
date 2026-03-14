//
//  ContactCollectionViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//

import UIKit


class ContactCollectionViewController: UIViewController {
    
    private var viewModel: ContactListViewModel
    private var viewCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
    
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.register(ContactCollectionCell.self, forCellWithReuseIdentifier: ContactCollectionCell.identifier)
        cv.register(LoadingCollectionCell.self, forCellWithReuseIdentifier: LoadingCollectionCell.identifier)
        
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
        loadData()
        setUpUI()
    }
    
    
    func setUpUI(){
        viewCollection.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(viewCollection)
        
        NSLayoutConstraint.activate([
            viewCollection.topAnchor.constraint(equalTo: view.topAnchor),
            viewCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        viewCollection.dataSource = self
        viewCollection.delegate = self
    }
    
    func loadData(){
        Task{
            try await viewModel.loadInitialData()
            viewCollection.reloadData()
        }
    }
    
}


extension ContactCollectionViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.isLoading == .loading ? viewModel.contacts.count + 1 : viewModel.contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.item == viewModel.contacts.count){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCollectionCell.identifier, for: indexPath) as! LoadingCollectionCell
            
            cell.start()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionCell.identifier, for: indexPath) as! ContactCollectionCell
        
        cell.configure(with: viewModel.contacts[indexPath.item])
        return cell
    }
}

extension ContactCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(indexPath.item == viewModel.contacts.count)
        {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
        
        let numColums: CGFloat = 3
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        
        let totalPaddings = layout.sectionInset.left + layout.sectionInset.right
        let totalSpacings = layout.minimumInteritemSpacing * (numColums - 1)
        
        let length = floor((collectionView.bounds.width - (totalPaddings + totalSpacings)) / numColums)
        
        return CGSize(width: length, height: length)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let threshold = viewModel.contacts.count - 5
        guard indexPath.item == threshold && viewModel.isLoading != .loading else{
            return
        }
        
        Task{
            viewModel.setLoadingState(loadingState: .loading)
            
            viewCollection.performBatchUpdates {
                viewCollection.insertItems(at: [IndexPath(row: viewModel.contacts.count, section: 0)])
            }
            do{
                let newContacts = try await viewModel.loadNextPage()

                if(!newContacts.isEmpty){
                    let range = viewModel.contacts.count..<(viewModel.contacts.count + newContacts.count)
                    let pathList = range.map { IndexPath(row: $0, section: 0)}
                    let loadingPath = IndexPath(row: viewModel.contacts.count, section: 0)
                    viewCollection.performBatchUpdates {
                        viewCollection.deleteItems(at: [loadingPath])
                        viewModel.appendContacts(newContacts)
                        viewCollection.insertItems(at: pathList)
                    }
                } else{
                    viewModel.resetLoadingState()
                }
                
            } catch
            {
                viewModel.resetLoadingState()
                print("Something wrong while fetching Data")
            }
        }
    }
}
