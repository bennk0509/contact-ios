//
//  CompositionalLayoutViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//
import UIKit

nonisolated enum Section {
    case main
}

class CompositionalLayoutViewController: UIViewController{
    private var viewModel: ContactListViewModel
    //Datasource
    private var dataSource: UICollectionViewDiffableDataSource<Section, ContactModel>!
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        
        cv.register(ContactCollectionCell.self, forCellWithReuseIdentifier: ContactCollectionCell.identifier)
        cv.register(LoadingFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier)
        return cv
    }()
    
    private let searchController: UISearchController = {
            let sc = UISearchController(searchResultsController: nil)
            sc.searchBar.placeholder = "Find Contact..."
            sc.obscuresBackgroundDuringPresentation = false
            return sc
        }()
    
    init(viewModel: ContactListViewModel)
    {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupSearchController()
        configureDataSource()
        loadData()
        collectionView.delegate = self
    }
    
    private func loadData(){
        Task{
            do{
                try await viewModel.loadInitialData()
                applySnapshot(with: viewModel.contacts)
            } catch{
                print("Failed to load contacts: \(error)")
            }
        }
    }
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    private func setUpUI(){
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section, ContactModel>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionCell.identifier, for: indexPath) as? ContactCollectionCell
            cell?.configure(with: itemIdentifier)
            return cell
        })
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoadingFooterView.identifier, for: indexPath) as? LoadingFooterView
            if self?.viewModel.isLoading == .loading {
                footer?.start()
            } else {
                footer?.stop()
            }
            return footer
        }
    }
    
    private func applySnapshot(with contacts: [ContactModel], animating: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,ContactModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(contacts, toSection: .main)
        Task {
            await dataSource.apply(snapshot, animatingDifferences: animating)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        
        section.boundarySupplementaryItems = [footer]
        //padding
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        //spacing between group
        section.interGroupSpacing = 10
    
        return UICollectionViewCompositionalLayout(section: section)
    }
}


extension CompositionalLayoutViewController: UICollectionViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        guard position > (contentHeight - frameHeight - 100),
              viewModel.isLoading == .rest,
              searchController.searchBar.text?.isEmpty ?? true else { return }
        Task{
            do{
                try await viewModel.loadNextPage()
                applySnapshot(with: viewModel.contacts)
            } catch{
                print("Eror load more: \(error)")
            }
        }
    }
}

extension CompositionalLayoutViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        Task {
            let completed = await viewModel.search(query: text)
            if(completed)
            {
                print("Apply Snapshot")
                applySnapshot(with: viewModel.filteredContacts)
            }
        }
    }
}
