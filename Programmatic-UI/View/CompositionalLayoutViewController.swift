//
//  CompositionalLayoutViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//
import UIKit

nonisolated enum Section: Hashable {
    case letter(String)
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
        cv.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
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
                applySnapshot(with: viewModel.groupedContacts)
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
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as? SectionHeaderView
                let section = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                if case .letter(let letter) = section {
                    header?.configure(with: letter)
                }
                return header
            }
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
    
    private func applySnapshot(with groups: [(letter: String, contacts: [ContactModel])], animating: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ContactModel>()
        for group in groups {
            let section = Section.letter(group.letter)
            snapshot.appendSections([section])
            snapshot.appendItems(group.contacts, toSection: section)
        }
        Task {
            await dataSource.apply(snapshot, animatingDifferences: animating)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 0

        // one global footer at the very bottom — like Apple Contacts
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let globalFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.boundarySupplementaryItems = [globalFooter]

        return UICollectionViewCompositionalLayout(section: section, configuration: config)
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
                applySnapshot(with: viewModel.groupedContacts)
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
//                print("Apply Snapshot")
                applySnapshot(with: viewModel.groupedFilteredContacts)
            }
        }
    }
}
