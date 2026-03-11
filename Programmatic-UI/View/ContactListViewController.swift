//
//  ViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-25.
//

import UIKit
//
class ContactListViewController: UIViewController {
    //
    private let viewModel: ContactListViewModel
    private let tableView = UITableView()
    
    
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
        setUpTableView()
        loadData()
        
    }
    
    private func setUpTableView()
    {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ContactCell.self, forCellReuseIdentifier: ContactCell.identifier)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.identifier)
        tableView.rowHeight = 60
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData(){
        Task {
            try await viewModel.loadInitialData()
            tableView.reloadData()
        }
    }
}
extension ContactListViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isLoading == .loading ? viewModel.contacts.count + 1 : viewModel.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == viewModel.contacts.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.identifier, for: indexPath) as! LoadingCell
            cell.start()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifier, for: indexPath) as! ContactCell
        let contact = viewModel.contacts[indexPath.row]
        cell.configure(with: contact)
        
        return cell
    }
}

extension ContactListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = viewModel.contacts.count - 5
        guard indexPath.row == threshold, viewModel.isLoading == .rest else {return}
        
        Task{
            let currentCount = viewModel.contacts.count
            viewModel.setLoadingState(loadingState: .loading)
            tableView.performBatchUpdates {
                tableView.insertRows(at: [IndexPath(row: currentCount, section: 0)], with: .none)
            }
            do {
                let newContacts = try await viewModel.loadNextPage()
                
                if !newContacts.isEmpty {
                    let range = currentCount..<(currentCount + newContacts.count)
                    let pathList = range.map { IndexPath(row: $0, section: 0) }
                    let loadingPath = IndexPath(row: currentCount, section: 0)
                    
                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: [loadingPath], with: .fade)
                        viewModel.appendContacts(newContacts)
                        tableView.insertRows(at: pathList, with: .fade)
                    })
                } else {
                    viewModel.resetLoadingState()
                    tableView.reloadData()
                }
            } catch {
                viewModel.resetLoadingState()
                print("Error loading data: \(error)")
            }
        }
    }
}
